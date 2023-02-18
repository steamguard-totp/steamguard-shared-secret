# steamguard-shared-secret
Obtain Steam Guard Mobile Authenticator shared secret from Android phone without root

# What this is
See above. This is BETA quality software for use as a reference implementation for more polished software to implement.
Use this on your main account at your own risk!

### Who this is for:
This is for you if you have an unrooted Android phone and would like to authenticate on both your phone and your PC.

### Who this is not for:
This is not for you if you have an iPhone or a rooted Android phone. This may not be for you (yet) if you
are not experienced with the command line and debugging on your own.

### Requirements
* JDK
* [Apktool](https://ibotpeaches.github.io/Apktool/)
* ADB
* Python 3
* Android SDK

Android SDK is required, if you are going to use Android 12+. If you have an
older Android version, and you want to skip installing SDK, you can use
a legacy mode with `--legacy-sign` command line switch (e.g. `./get_code.sh
--legacy-sign`)

Installing Android SDK can be a tad involved but below are some hints for
a minimal, CLI-only, temporary install:

1. Visit the [Android Studio
   site](https://developer.android.com/studio#command-tools) and scroll down to
   "Command line tools only".
2. Download and unpack the `.zip` for your platform.
3. Install `zipalign` and `apksigner`:
   ```sh
   /path/to/your/commandlinetools/cmdline-tools/bin/sdkmanager \
       --sdk_root=/path/to/your/commandlinetools \
       --install 'cmdline-tools;latest'
   ```
4. Now the two needed CLI tools will be available in some versioned
   subdirectory of that directory.

   You can _temporarily_ add it to your `PATH` if you've just installed it for
   this one-time task. If you have `realpath` and `dirname` installed from the
   GNU suite of tools this can be automated, otherwise you'll need to find the
   correct path manually. E.g.:
   ```sh
   export PATH="${PATH}$(find /path/to/your/commandlinetools -name zipalign \
       | xargs realpath | xargs dirname | xargs printf ':%s')"
   ```

   Double-check that worked with `which zipalign` and `which apksigner`.
5. For as long as that temporary `PATH` variable exists (and is correct) the
   `get_code.sh` script should be able to find them when you run it. You can
   delete the commandlinetools directory once you're done and exiting your
   shell will forget the temporary `PATH` addition.

### Supported Environments
* Linux
* Windows + Git Bash ([#3](https://github.com/steamguard-totp/steamguard-shared-secret/issues/3))
* Mac (`brew install apktool android-platform-tools android-sdk gnu-sed python`)

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
