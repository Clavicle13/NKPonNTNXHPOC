#!/usr/bin/env python3
################################################################################################
#
#
#
################################################################################################

import argparse
import json
import os
import re
from datetime import datetime
from pathlib import Path

def slugify(text: str, max_len: int = 50) -> str:
    """Create a filesystem-safe slug from the first user prompt."""
    clean = re.sub(r"[^a-zA-Z0-9\s-]", "", text).strip().lower()
    slug = re.sub(r"[\s_-]+", "-", clean)[:max_len].strip("-")
    return slug or "untitled-session"


def convert_session(jsonl_path: Path, out_dir: Path) -> bool:
    """Convert a single transcript_full.jsonl into a Markdown file."""
    uuid = jsonl_path.parents[2].name
    mtime = jsonl_path.stat().st_mtime
    date_str = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d")

    turns = []
    first_prompt = ""

    with jsonl_path.open("r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                print(f"[WARN] Skipping malformed JSON at {jsonl_path}:{line_num}")
                continue

            rec_type = rec.get("type")
            content = rec.get("content", "")

            if rec_type == "USER_INPUT" and content:
                if not first_prompt:
                    first_prompt = content
                turns.append(("User", content))
            elif rec_type == "PLANNER_RESPONSE" and content:
                turns.append(("Assistant", content))

    # Skip empty sessions that have no actual conversation turns
    if not turns:
        return False

    slug = slugify(first_prompt)
    out_file = out_dir / f"{date_str}_{slug}_{uuid[:8]}.md"

    with out_file.open("w", encoding="utf-8") as out:
        out.write(f"# {first_prompt.splitlines()[0][:80]}\n\n")
        out.write(f"- **Session UUID:** `{uuid}`\n")
        out.write(f"- **Last Modified:** {datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        out.write("---\n\n")

        for role, text in turns:
            out.write(f"## {role}\n\n{text.strip()}\n\n---\n\n")

    return True


def main():
    parser = argparse.ArgumentParser(
        description="Iteratively export all agy conversations to Markdown."
    )
    parser.add_argument(
        "--source",
        type=Path,
        default=Path.home() / ".gemini" / "antigravity-cli" / "brain",
        help="Path to the agy brain directory (default: ~/.gemini/antigravity-cli/brain)",
    )
    parser.add_argument(
        "--dest",
        type=Path,
        default=Path.home() / "agy-exports",
        help="Target output directory outside ~/.gemini (default: ~/agy-exports)",
    )
    args = parser.parse_args()

    source_dir = args.source.expanduser().resolve()
    dest_dir = args.dest.expanduser().resolve()
    gemini_root = (Path.home() / ".gemini").resolve()

    # Guardrail: prevent writing inside ~/.gemini
    if gemini_root == dest_dir or gemini_root in dest_dir.parents:
        raise ValueError(f"Destination {dest_dir} must not be inside {gemini_root}")

    if not source_dir.exists():
        raise FileNotFoundError(f"Source directory not found: {source_dir}")

    dest_dir.mkdir(parents=True, exist_ok=True)

    exported = 0
    skipped = 0

    for session_dir in sorted(source_dir.iterdir()):
        if not session_dir.is_dir():
            continue

        # Prefer full transcript; fall back to clipped transcript if needed
        logs_dir = session_dir / ".system_generated" / "logs"
        transcript = logs_dir / "transcript_full.jsonl"
        if not transcript.exists():
            transcript = logs_dir / "transcript.jsonl"
        if not transcript.exists():
            skipped += 1
            continue

        if convert_session(transcript, dest_dir):
            exported += 1
        else:
            skipped += 1

    print(f"Done. Exported {exported} conversations to {dest_dir} (skipped {skipped} empty/incomplete sessions).")


if __name__ == "__main__":
    main()
