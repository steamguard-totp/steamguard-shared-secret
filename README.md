# steamguard-shared-secret
Obtain Steam Guard Mobile Authenticator shared secret from Android phone without root

# What this is
See above. This is BETA quality software for use as a reference implementation for more polished software to implement.
Use this on your main account at your own risk!

### Who this is for:
This is for you if you have an unrooted Android phone and would like to authenticate on both your phone and your PC.

### Who this is not for:
This is not for you if you have a Windows PC, an iPhone, or a rooted Android phone. This may not be for you (yet) if you
are not experienced with the command line and debugging on your own.

### Requirements
* JDK
* [Apktool](https://ibotpeaches.github.io/Apktool/)
* Linux (maybe Mac but I have not and will not test it)
* ADB
* Python 2

# How it does it
If you phone is rooted, don't use this. Do this instead:
```
$ adb shell
device:/ $ su
device:/ # cat /data/data/com.valvesoftware.android.steam.community/files/*
```

If your phone is *not* rooted, you'll have to use this script, or someone else's variation of it.

You used to be able to just `adb backup -f steam.ab -noapk com.valvesoftware.android.steam.community` and get the `shared_secret`,
but Valve fixed that. Source: https://www.reddit.com/r/SteamBot/comments/63s72f/help_how_do_i_get_the_shared_secret_from_the/

Here are the ~~ugly hacks~~ simple steps this script uses to work around that:
* Disassembles the APK
* Re-enables backups
* Rebuilds the APK and signs it
* Installs the patched APK
* Does the backup thing

# What's the catch?
The catch is that this script essentially builds its own version of the Steam app. You will no longer get updates from the Google
Play store, and after running this script, you will probably have a 7 day trade restriction because it requires removing and
re-adding the authenticator.

You will also have reduced security due to this re-enabling backups, which could be a vulnerability depending on your
threat models. See [#1](https://github.com/steamguard-totp/steamguard-shared-secret/issues/1).
