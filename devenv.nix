{ pkgs, ... }:

{
  android = {
    enable = true;
    platforms.version = [ "35" ];
    buildTools.version = [ "35.0.0" ];
    platformTools.enable = true;
    emulator.enable = true;
    ndk = {
      enable = true;
      version = "27.1.12297006";
    };
    reactNative.enable = true;
  };

  packages = [ pkgs.nodejs-18_x ];

  enterShell = ''
    export ANDROID_HOME=$ANDROID_SDK_ROOT
    echo "Android development environment for clebr-mobile ready."
  '';

  scripts.create-avd.exec = "avdmanager create avd --force --name clebr-emulator --package 'system-images;android-35;google_apis;x86_64'";

  processes.emulator.exec = "emulator -avd clebr-emulator";
  processes.react-native.exec = "npm start";
  processes.run-android.exec = "npm run android";

}
