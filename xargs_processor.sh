#!/bin/sh
b64jq() { base64 -d | jq "$@"; }

gh release list --json tagName,isDraft,isPrerelease | \
jq -e "map(select(.tagName==\"$(printf "$1" | b64jq .file | awk -F '_' '{print $2}')/$(printf $1 | b64jq -r .channel)/$(printf $1 | b64jq -r .chrome_version)\"))==[]" >/dev/null && \
env BOARD="$(printf "$1" | b64jq ".file" | awk -F _ '{print $3}')" $(printf $1 | b64jq -rcM '[. | to_entries | .[] | (.key | ascii_upcase) + "=" + .value] | join(" ")') ./process_info.sh
