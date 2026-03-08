class AppConstants {
  static const String appName = 'Termax';
  static const String version = '1.0.0';
  static const String packageName = 'com.termax.app';

  /// Matches ANSI escape sequences (e.g. color codes in terminal output).
  static final ansiEscape = RegExp(r'\x1b\[[0-9;]*[a-zA-Z]');

  static const String authorName = 'Keyy';
  static const String authorEmail = 'keyy@email.com';
  static const String githubUrl = 'https://github.com/keydelrey/termax';
  static const String license = 'MIT';

  static const String channelName = 'com.termax.app/native';
  static const String eventChannelName = 'com.termax.app/terminal_logs';

  static const String ubuntuRootfsUrl =
      'https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.3-base-';
  static const String rootfsArm64 = '${ubuntuRootfsUrl}arm64.tar.gz';
  static const String rootfsArmhf = '${ubuntuRootfsUrl}armhf.tar.gz';
  static const String rootfsAmd64 = '${ubuntuRootfsUrl}amd64.tar.gz';

  static String getRootfsUrl(String arch) {
    switch (arch) {
      case 'aarch64':
        return rootfsArm64;
      case 'arm':
        return rootfsArmhf;
      case 'x86_64':
        return rootfsAmd64;
      default:
        return rootfsArm64;
    }
  }
}
