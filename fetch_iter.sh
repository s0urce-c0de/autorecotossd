#!/bin/sh

curl "https://dl.google.com/dl/edgedl/chromeos/recovery/recovery2.json" | \
  jq -rM "unique_by(.file) | .[] | {channel,url,file,version,chrome_version,md5,sha1} | @base64" | \
  xargs -P "${THREADS:-1}" -n 1 ./xargs_processor.sh
