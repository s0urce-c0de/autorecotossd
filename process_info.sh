#!/bin/sh

TMP="${TMP:-$(mktEmpdir -d)}"
DL_PATH="$(realpath "$(basename "$URL")")"
printf "Using $TMP as the temporary directory\n"
printf "Moving into the temporary directory\n"
cd $TMP
printf "Downloading $URL into $DL_PATH\n"
# curl -o "$DL_PATH" "$URL"
printf "Starting hash checks\n"
if [ -z $SHA1 ]; then
  printf "Skipping SHA1"
else
  printf "Preloaded hash: $SHA1\nCalculating new hash\n"
  SHA1_CALCULATED_HASH="$(openssl dgst -sha1 -hex $DL_PATH | awk '{ print $NF }')"
  printf "Got $SHA1_CALCULATED_HASH\n"
  if [ "$SHA1" != "$SHA1_CALCULATED_HASH" ]; then
    printf "Invalid SHA1 hash! Aborting.\n"
    exit
  else
    printf "Hashes match!\n"
  fi
fi

if [ -z $MD5 ]; then
  printf "Skipping MD5"
else
  printf "Preloaded hash: $MD5\nCalculating new hash\n"
  MD5_CALCULATED_HASH="$(openssl dgst -md5 -hex $DL_PATH | awk '{ print $NF }')"
  printf "Got $MD5_CALCULATED_HASH\n"
  if [ "$MD5" != "$MD5_CALCULATED_HASH" ]; then
    printf "Invalid MD51 hash! Aborting.\n"
    exit
  else
    printf "Hashes Match!\n"
  fi
fi

printf "Extracting ZIP archive\n"
# unzip $DL_PATH $FILE
printf "Running RecoToSSD"
./recotossd.sh