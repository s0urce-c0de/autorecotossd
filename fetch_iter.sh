#!/bin/sh
b64jq() {
  base64 -d | jq "$@"
}
for i in $(curl https://dl.google.com/dl/edgedl/chromeos/recovery/recovery2.json | jq -rM "unique_by(.file) | .[] | {channel,url,file,version,chrome_version,md5,sha1} | @base64")
do
  gh release list --json tagName,isDraft,isPrerelease | \
  jq -e "map(select(.isDraft==false and .isPrerelease==false and .tagName==\"$(printf $i | b64jq .file | awk -F '_' '{print $2}')-$(printf $i | b64jq -r .chrome_version)\"))==[]" >/dev/null && \
  env BOARD="$(echo chromeos_10323.62.0_butterfly_recovery_stable-channel_mp-v4.bin.zip | awk -F _ '{print $3}')" $(printf $i | b64jq -rcM '[. | to_entries | .[] | (.key | ascii_upcase) + "=" + .value] | join(" ")') ./process_info.sh
done