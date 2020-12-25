import 'package:package_info/package_info.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum Ordering { Lesser, Greater, Equal }

class Version extends Equatable {
  final int major;
  final int minor;
  final int patch;
  final int build;

  Version({this.major, this.minor, this.patch, this.build});

  static Version fromString(String string, [int build]) {
    var majorEndIndex = string.indexOf('.');
    if (majorEndIndex < 0) return null;

    var major = int.tryParse(string.substring(0, majorEndIndex));

    var minorEndIndex = string.indexOf('.', majorEndIndex + 1);
    if (minorEndIndex < 0) return null;
    var minor =
        int.tryParse(string.substring(majorEndIndex + 1, minorEndIndex));

    var buildStartIndex = string.indexOf('+', minorEndIndex);
    int patch;

    if (buildStartIndex < 0) {
      patch = int.tryParse(string.substring(minorEndIndex + 1));
    } else {
      patch =
          int.tryParse(string.substring(minorEndIndex + 1, buildStartIndex));
      build = int.tryParse(string.substring(buildStartIndex + 1));
    }

    if (major == null || minor == null || patch == null) {
      return null;
    }

    return Version(major: major, minor: minor, patch: patch, build: build);
  }

  Ordering order(Version other) {
    // Major lesser
    if (this.major < other.major) return Ordering.Lesser;
    // Major greater
    if (this.major > other.major) return Ordering.Greater;

    // Major equal

    // Minor lesser
    if (this.minor < other.minor) return Ordering.Lesser;
    // Minor greater
    if (this.minor > other.minor) return Ordering.Greater;

    // Minor equal

    // Patch lesser
    if (this.patch < other.patch) return Ordering.Lesser;
    // Patch greater
    if (this.patch > other.patch) return Ordering.Greater;

    // Patch equal

    // No build in both - so Versions are equal
    if (this.build == null && other.build == null) return Ordering.Equal;
    // No build on this, but other has build so take version with no build as lesser
    if (this.build == null) return Ordering.Lesser;
    // No build on other, but this has build so take version with build as greater
    if (other.build == null) return Ordering.Greater;

    // Build lesser
    if (this.build < other.build) return Ordering.Lesser;
    // Build Greater
    if (this.build > other.build) return Ordering.Greater;

    // Build Equal
    return Ordering.Equal;
  }

  bool operator <(Version other) {
    return order(other) == Ordering.Lesser;
  }

  bool operator >(Version other) {
    return order(other) == Ordering.Greater;
  }

  bool operator >=(Version other) {
    var order = this.order(other);
    return order == Ordering.Greater || order == Ordering.Equal;
  }

  bool operator <=(Version other) {
    var order = this.order(other);
    return order == Ordering.Lesser || order == Ordering.Equal;
  }

  @override
  List<Object> get props => [major, minor, patch, build];

  toString() {
    return '$major.$minor.$patch${build != null ? "+$build" : ""} }';
  }
}

Future<Version> getLatestTagVersion() async {
  try {
    var response = await http.get(
        'https://api.github.com/repos/Lutetium-Vanadium/Music-Flutter/tags');

    if (response.statusCode != 200) throw response.headers['status'];

    return Version.fromString(jsonDecode(response.body)[0]['name']);
  } catch (error) {
    print(error);
    return null;
  }
}

class Updater {
  Version version;

  Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    this.version = Version.fromString(
        packageInfo.version.substring(0, packageInfo.version.indexOf('-')),
        int.parse(packageInfo.buildNumber));
  }

  Future<Version> checkForUpdate() async {
    while (version == null) {
      await Future.delayed(Duration(seconds: 1));
    }
    var latestVersion = await getLatestTagVersion();
    if (latestVersion > this.version) {
      return latestVersion;
    }

    return null;
  }
}
