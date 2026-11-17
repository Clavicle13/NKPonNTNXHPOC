SRC_CTR=$(ncli ctr ls id=1374 | grep -E '^\s*Name\s*:' | awk -F': ' '{print $2}')

for c in studentA studentB studentC studentD; do
  acli image.create "win2022-${c}" \
    source_url="nfs://10.136.231.37/${SRC_CTR}/.acropolis/vmdisk/0dfa04c1-1753-41e4-bd61-a9b0f231d60d" \
    container="${c}" \
    image_type=kDiskImage
done
