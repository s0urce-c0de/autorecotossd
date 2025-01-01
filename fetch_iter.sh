#!/bin/sh

curl "https://dl.google.com/dl/edgedl/chromeos/recovery/recovery2.json" | \
  jq -rM "unique_by(.file) | .[] | {channel,url,file,version,chrome_version,md5,sha1} | @base64" | \
  xargs -0 -n1 -P1 sh -c "sleep ${DELAY:-5}"'s; printf "%s\0" "$0"' | \
  xargs --max-args 1 --max-procs="${THREADS:-1}" ./xargs_processor.sh
