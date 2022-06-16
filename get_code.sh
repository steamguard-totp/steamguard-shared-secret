#!/usr/bin/env bash

command -v "python3"
if [[ $? -ne 0 ]]; then
    printf 'Missing python3. Installed under a different name?\n'
    exit 1
fi

# Check for gsed for MacOS
if [ -x "$(command -v gsed)" ]; then
    printf 'Using gsed\n'
    SEDVAR = "gsed"
else
    SEDVAR = "sed"
fi

# Abort on errors.
set -e

printf 'Make sure Steam Guard Mobile Authenticator is DISABLED or you will be
locked out of your Steam account!
'
read -rp 'Press [ENTER] when you are ready, or Ctrl-C to exit.'

printf '[ Pulling APK from device ]\n'
adb shell pm list packages \
    | grep -m1 steam.community \
    | cut -d: -f2 \
    | xargs -r -n1 -I@ adb shell pm path @ \
    | cut -d: -f2 \
    | xargs -r -n1 -I@ adb pull @ steam.apk

printf '\n[ Disassembling APK ]\n'
apktool d steam.apk
rm steam.apk

printf '\n[ Patching AndroidManifest.xml ]\n'
$SEDVAR -i 's/android:allowBackup="false"/android:allowBackup="true"/g' steam/AndroidManifest.xml

printf '\n[ Rebuilding APK ]\n'
apktool b steam

PASS=$(tr -cd "[:digit:]" < /dev/urandom | head -c 8)

printf '\n[ Generating signing key ]\n'
keytool -genkey -noprompt \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass $PASS \
    -keypass $PASS \
    -keystore key.keystore \
    -alias attemptone \
    -dname "CN=example.com, OU=dont, O=use, L=this, S=in, C=production"

printf '\n[ Signing APK ]\n'
jarsigner \
    -sigalg SHA1withRSA \
    -digestalg SHA1 \
    -keystore key.keystore \
    -storepass $PASS \
    -keypass $PASS \
    steam/dist/steam.apk \
    attemptone
rm key.keystore

printf '\n[ Uninstalling Steam App ]\n'
adb uninstall com.valvesoftware.android.steam.community

printf '\n[ Installing patched APK ]\n'
adb install steam/dist/steam.apk
adb shell monkey -p com.valvesoftware.android.steam.community 1

printf '
Sign in to Steam and ENABLE Steam Guard Mobile Authenticator.
'
read -rp 'Press [ENTER] when you are ready.'

printf '
Extracting data. Please confirm "back up my data" on device. DO NOT set a password.
'
adb backup -f backup.ab com.valvesoftware.android.steam.community
dd if=backup.ab bs=24 skip=1 | python3 -c "import zlib,sys;sys.stdout.buffer.write(zlib.decompress(sys.stdin.buffer.read()))" | tar -xf -

cat apps/com.valvesoftware.android.steam.community/f/* | python3 -m json.tool
