#!/bin/sh
b64jq() { base64 -d | jq "$@"; }

gh release list --json tagName | \
jq -e "map(select(.tagName==\"$(printf "$1" | b64jq -r .file | awk -F '_' '{print $3}')/$(printf $1 | b64jq -r .channel)/v$(printf $1 | b64jq -r .version)\"))==[]" >/dev/null && \
env BOARD="$(printf "$1" | b64jq ".file" | awk -F _ '{print $3}')" $(printf $1 | b64jq -rcM '[. | to_entries | .[] | (.key | ascii_upcase) + "=" + .value] | join(" ")') ./process_info.sh
