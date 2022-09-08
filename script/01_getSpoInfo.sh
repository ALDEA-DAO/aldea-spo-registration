#!/bin/bash
source ./env

GetSPOs () {
ADAFOLIO=() && INFO_BATCH=()
ADAFOLIO+=($(curl -s $FOLIO_URL$FOLIO_ID | jq -r .pools[].id));

for d in "${ADAFOLIO[@]}"; do
	INFO1="" && INFO2=""
	echo "Checking pool $d"
#	echo "Getting basic info"
	INFO1=$(curl -s -H "project_id: $KEY" $APIUrl/pools/$d/metadata | jq 'del(.pool_id)');
#	echo Getting Meta URL
	Meta=$(echo ${INFO1} | jq -r .url)
#	echo "Getting extra metadata if exists"
	XMeta=$(curl -s $Meta | jq -r .extended)
	if [[ "${XMeta}" == "" ]] || [ -z "${XMeta}" ] ; then echo "No extra meta"; else INFO2=$(curl -s "${XMeta}" | jq .info); fi
	
	INFO_BATCH+=$(jq --slurp 'add' <(echo "$INFO1") <(echo "$INFO2") | jq 'del(.company,.rss,.about,.url,.hash,.url_png_icon_64x64)')
done

INFO_FINAL=$(echo $INFO_BATCH | jq -s .)
echo -e "FINAL INFO: "
echo $INFO_FINAL | jq . | tee ./registry.json

}

GetSPOs
