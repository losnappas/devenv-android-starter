{ pkgs, inputs, ... }:

let
  sdk = (import inputs.android-nixpkgs { }).sdk (sdkPkgs:
    with sdkPkgs; [
      cmdline-tools-latest
      build-tools-34-0-0
      platform-tools
      platforms-android-34
      emulator
      system-images-android-34-google-apis-x86-64
    ]);
in
{
  # https://devenv.sh/languages/
  # languages.nix.enable = true;
  languages.kotlin.enable = true;
  languages.java.enable = true;

  # https://devenv.sh/basics/
  env.GREET = "devenv";

  env.ANDROID_HOME = "${sdk}/share/android-sdk";
  env.ANDROID_SDK_ROOT = "${sdk}/share/android-sdk";
  # env.ANDROID_NDK_HOME = "${sdk}/share/android-sdk/ndk/25.2.9519653";

  # https://devenv.sh/packages/
  packages = [ ];

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from $GREET";
  scripts.gradlew.exec = "./gradlew $@";
  scripts.create-avd.exec = "avdmanager create avd --force --name phone --package 'system-images;android-34;google_apis;x86_64'";

  # These processes will all run whenever we run `devenv up`
  processes.emulator.exec = "emulator -avd phone -skin 720x1280";
  processes.rebuilds.exec = "./gradlew app:installDebug -t";

  enterShell = ''
    export PATH="${sdk}/bin:$PATH"
    ${(builtins.readFile "${sdk}/nix-support/setup-hook")}
    ANDROID_USER_HOME=$(pwd)/.android
    ANDROID_AVD_HOME=$(pwd)/.android/avd

    export ANDROID_USER_HOME
    export ANDROID_AVD_HOME

    test -e "$ANDROID_USER_HOME" || mkdir -p "$ANDROID_USER_HOME"
    test -e "$ANDROID_AVD_HOME" || mkdir -p "$ANDROID_AVD_HOME"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
