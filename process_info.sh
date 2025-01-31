#!/bin/sh

[ "${PUSH_TO_GITHUB:-0}" -eq 1 ] && \
git ls-remote --tags --exit-code "${GIT_REPO:-.}" "$BOARD/$CHANNEL/v$VERSION" >/dev/null && \
exit

TMP="${TMP:-$(mktemp -d)}"
DL_PATH="$(basename "$URL")"
printf "Using $TMP as the temporary directory\n"
printf "Moving into the temporary directory\n"
cd "$TMP"
printf "Downloading $URL into $DL_PATH\n"
curl --no-progress-meter -o "$DL_PATH" "$URL"
printf "Starting hash checks\n"
if [ -z $SHA1 ]; then
  printf "Skipping SHA1\n"
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
  printf "Skipping MD5\n"
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
yes | unzip -j $DL_PATH -d .
printf "Running RecoToSSD. Enter sudo password if needed\n"
sudo "$OLDPWD/recotossd.sh" "$FILE"
if [ "${PUSH_TO_GITHUB:-0}" -eq 1 ]; then
  xz -vvz9ec -T 1 $FILE > $FILE.xz
  xz -vvz9ec -T 1 $FILE > base.xz
  cd -
  ls -la $OLDPWD
  gh release create "$BOARD/$CHANNEL/v$VERSION" --title "RecoToSSD $(printf "$BOARD" | awk -vFS="" -vOFS="" '{$1=toupper($1);print $0}') v$CHROME_VERSION (Platform Version: $VERSION) for $(printf $CHANNEL | tr "[:upper:]" "[:lower:]")-channel" --notes "RecoToSSD Release for board $BOARD:
Chrome Version: $CHROME_VERSION
ChromeOS/Platform Version: $VERSION
Channel: $(printf $CHANNEL | tr "[:upper:]" "[:lower:]")" "$OLDPWD/$FILE.xz#$BOARD RecoToSSD v$CHROME_VERSION (Platform: v$VERSION).xz" "$OLDPWD/base.xz#Base Recovery Image (Chome v$CHROME_VERSION) (ChromeOS Version: v$VERSION).xz"
  rm -f $OLDPWD/$FILE.xz $OLDPWD/$FILE $OLDPWD/$DL_PATH
  rm -rf $OLDPWD
else
  cd -
  cp $OLDPWD/$FILE .
fi
