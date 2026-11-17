SRC_CTR=$(ncli ctr ls id=1374 | grep -E '^\s*Name\s*:' | awk -F': ' '{print $2}')
echo "Source container: ${SRC_CTR}"

for c in instructor studentA studentB studentC studentD; do
  acli image.create "rocky9-${c}" \
    source_url="nfs://10.136.231.37/${SRC_CTR}/.acropolis/vmdisk/5b5e8dde-1ba8-4bb7-bae1-e4256f2a9f30" \
    container="${c}" \
    image_type=kDiskImage
done
