import 'dart:math';

class Version {
  late int major;
  late int minor;
  late int patch;

  Version(String versionString) {
    if (versionString.startsWith('"')) {
      versionString = versionString.substring(1, versionString.length - 1);
    }

    List<String> version = versionString.split('.');
    major = int.parse(version[0]);
    minor = int.parse(version[1]);
    patch = int.parse(version[2]);

    print('## version: $major $minor $patch');
  }
}
