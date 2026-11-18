# <USER_REQUEST>

- **Session UUID:** `1c51e301-feb5-47c0-8479-be99359df4b6`
- **Last Modified:** 2026-11-18 06:18:33

---

## User

<USER_REQUEST>
List all the Prism Central MCP Tools
</USER_REQUEST>
<ADDITIONAL_METADATA>
The current local time is: 2026-11-18T06:13:35Z.
</ADDITIONAL_METADATA>
<USER_SETTINGS_CHANGE>
The user changed setting `Model Selection` from None to Gemini 4 Hydrogen (Low). No need to comment on this change if the user doesn't ask about it. If reporting what model you are, please use a human readable name instead of the exact string.
</USER_SETTINGS_CHANGE>

---

## Assistant

The Prism Central MCP server in [`ntnx-api-mcp-server`](file:///home/nutanix/ntnx-api-mcp-server) exposes two categories of MCP tools (defined in [`runtime_dispatcher.py`](file:///home/nutanix/ntnx-api-mcp-server/src/tools/runtime_dispatcher.py#L63-L88)):

### 1. Progressive Discovery Tools
- `listOperations` — Lists available API operations (supports pagination via `limit` and `offset`).
- `getOperationSchema` — Retrieves the schema for a specific API operation.
- `getCodeSample` — Retrieves a code sample for an operation.
- `getOperationPermissions` — Retrieves the required permissions for an operation.

### 2. Namespace Execution Tools (`<namespace>_execute`)
One execution tool per Nutanix v4 API namespace loaded from [`artifacts/`](file:///home/nutanix/ntnx-api-mcp-server/artifacts):
- `aiops_execute`
- `clustermgmt_execute`
- `datapolicies_execute`
- `dataprotection_execute`
- `iam_execute`
- `licensing_execute`
- `lifecycle_execute`
- `microseg_execute`
- `monitoring_execute`
- `multidomain_execute`
- `networking_execute`
- `objects_execute`
- `prism_execute`
- `security_execute`
- `storage_execute`
- `vmm_execute`
- `volumes_execute`

---

