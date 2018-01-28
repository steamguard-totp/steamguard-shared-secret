#!/usr/bin/env bash

printf 'Make sure Steam Guard Mobile Authenticator is DISABLED or you will be
locked out of your Steam account!
'
read -rp 'Press [ENTER] when you are ready, or Ctrl-C to exit.'

printf '[ Pulling APK from device ]\n'
adb pull /data/app/com.valvesoftware.android.steam.community-1/base.apk steam.apk

printf '\n[ Disassembling APK ]\n'
apktool d steam.apk
rm steam.apk

printf '\n[ Patching AndroidManifest.xml ]\n'
sed -i 's/android:allowBackup="false"/android:allowBackup="true"/g' steam/AndroidManifest.xml

printf '\n[ Rebuilding APK ]\n'
apktool b steam

printf '\n[ Generating signing key ]\n'
STOREPASS=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
KEYPASS=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
keytool -genkey -noprompt \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STOREPASS" \
    -keypass "$KEYPASS" \
    -keystore key.keystore \
    -alias alias \
    -dname "CN=example.com, OU=dont, O=use, L=this, S=in, C=production"

printf '\n[ Signing APK ]\n'
jarsigner \
    -sigalg SHA1withRSA \
    -digestalg SHA1 \
    -keystore key.keystore \
    -storepass "$STOREPASS" \
    -keypass "$KEYPASS" \
    steam/dist/steam.apk \
    alias
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
dd if=backup.ab bs=24 skip=1 | python2 -c "import zlib,sys;sys.stdout.write(zlib.decompress(sys.stdin.read()))" | tar -xf -

cat apps/com.valvesoftware.android.steam.community/f/*
