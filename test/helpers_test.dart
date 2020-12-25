import 'package:flutter_test/flutter_test.dart';

import 'package:music/models/pair.dart';
import 'package:music/helpers/displace.dart' as displace;
import 'package:music/helpers/formatLength.dart' as formatLength;
import 'package:music/helpers/generateSubtitle.dart' as subtitle;
import 'package:music/helpers/generateUri.dart' as uri;
import 'package:music/helpers/version.dart';

void main() {
  group('Displace Tests', () {
    var list = List.generate(10, (index) => index);

    test('displace', () {
      expect(displace.displace(list, 4), [4, 5, 6, 7, 8, 9, 0, 1, 2, 3]);
      expect(displace.displace(list, 8), [8, 9, 0, 1, 2, 3, 4, 5, 6, 7]);
      expect(displace.displace(list, 0), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(displace.displace(list, 9), [9, 0, 1, 2, 3, 4, 5, 6, 7, 8]);
    });

    test('displaceWithoutIndex', () {
      expect(
        displace.displaceWithoutIndex(list, 4),
        [5, 6, 7, 8, 9, 0, 1, 2, 3],
      );
      expect(
        displace.displaceWithoutIndex(list, 8),
        [9, 0, 1, 2, 3, 4, 5, 6, 7],
      );
      expect(
        displace.displaceWithoutIndex(list, 0),
        [1, 2, 3, 4, 5, 6, 7, 8, 9],
      );
      expect(
        displace.displaceWithoutIndex(list, 9),
        [0, 1, 2, 3, 4, 5, 6, 7, 8],
      );
    });
  });

  group('Format Length', () {
    test('formatLength', () {
      expect(formatLength.formatLength(23), '0:23');
      expect(formatLength.formatLength(69), '1:09');
      expect(formatLength.formatLength(176), '2:56');
      expect(formatLength.formatLength(365), '6:05');
      expect(formatLength.formatLength(420), '7:00');
    });

    test('formatTime', () {
      expect(formatLength.formatTime(23, 37), Pair('0:23', '0:37'));
      expect(formatLength.formatTime(69, 200), Pair('1:09', '3:20'));
      expect(formatLength.formatTime(176, 1000), Pair('02:56', '16:40'));
      expect(formatLength.formatTime(365, 600), Pair('06:05', '10:00'));
      expect(formatLength.formatTime(420, 590), Pair('7:00', '9:50'));
    });
  });

  group('Generate Subtitles', () {
    test('No songs and artist', () {
      expect(
        subtitle.generateSubtitle(type: 'Album'),
        'Album',
      );
    });
    test('With songs', () {
      expect(
        subtitle.generateSubtitle(type: 'Album', numSongs: 45),
        'Album · 45 songs',
      );

      expect(
        subtitle.generateSubtitle(type: 'Album', numSongs: 1),
        'Album · 1 song',
      );
    });

    test('With artist', () {
      expect(
        subtitle.generateSubtitle(type: 'Album', artist: 'Artist'),
        'Album · Artist',
      );
    });
  });

  group('Generate URI', () {
    var base = 'http://example.com/';

    test('No params', () {
      expect(uri.generateUri(base).toString(), base);
      expect(uri.generateUri(base, {}).toString(), base);
    });

    test('One param', () {
      expect(uri.generateUri(base, {'hello': 'world'}).toString(),
          '$base?hello=world');
    });

    test('Multiple params', () {
      expect(
        uri.generateUri(base, {
          'hello': 'world',
          'param2': 'value',
        }).toString(),
        '$base?hello=world&param2=value',
      );
      expect(
        uri.generateUri(base, {
          'hello': 'world',
          'param3': 'value3',
          'param4': 'value4',
        }).toString(),
        '$base?hello=world&param3=value3&param4=value4',
      );
    });
  });

  group('Version', () {
    test('Parse simple version', () {
      expect(Version.fromString('1.1.1+2'),
          Version(major: 1, minor: 1, patch: 1, build: 2));
    });

    test('Parse no build', () {
      expect(
          Version.fromString('1.1.1'), Version(major: 1, minor: 1, patch: 1));
    });

    test('Fail parse illegal', () {
      expect(Version.fromString('1+1.1'), null);
    });

    test('Use provided build', () {
      expect(Version.fromString('1.1.1', 2),
          Version(major: 1, minor: 1, patch: 1, build: 2));
    });

    test('Override provided build', () {
      expect(Version.fromString('1.1.1+3', 2),
          Version(major: 1, minor: 1, patch: 1, build: 3));
    });

    test('Major version difference', () {
      var baseVersion = Version(major: 1, minor: 0, patch: 0);

      var versions = [
        [Version(major: 0, minor: 0, patch: 0), true, false, false],
        [Version(major: 1, minor: 0, patch: 0), false, true, false],
        [Version(major: 2, minor: 0, patch: 0), false, false, true],
      ];

      for (var version in versions) {
        expect((version[0] as Version) < baseVersion, version[1]);
        expect((version[0] as Version) == baseVersion, version[2]);
        expect((version[0] as Version) > baseVersion, version[3]);
      }
    });

    test('Minor version difference', () {
      var baseVersion = Version(major: 0, minor: 1, patch: 0);

      var versions = [
        [Version(major: 0, minor: 0, patch: 0), true, false, false],
        [Version(major: 0, minor: 1, patch: 0), false, true, false],
        [Version(major: 0, minor: 2, patch: 0), false, false, true],
      ];

      for (var version in versions) {
        expect((version[0] as Version) < baseVersion, version[1]);
        expect((version[0] as Version) == baseVersion, version[2]);
        expect((version[0] as Version) > baseVersion, version[3]);
      }
    });

    test('Patch version difference', () {
      var baseVersion = Version(major: 0, minor: 0, patch: 1);

      var versions = [
        [Version(major: 0, minor: 0, patch: 0), true, false, false],
        [Version(major: 0, minor: 0, patch: 1), false, true, false],
        [Version(major: 0, minor: 0, patch: 2), false, false, true],
      ];

      for (var version in versions) {
        expect((version[0] as Version) < baseVersion, version[1]);
        expect((version[0] as Version) == baseVersion, version[2]);
        expect((version[0] as Version) > baseVersion, version[3]);
      }
    });

    test('Build version difference', () {
      var baseVersion = Version(major: 0, minor: 0, patch: 0, build: 1);

      var versions = [
        [Version(major: 0, minor: 0, patch: 0), true, false, false],
        [Version(major: 0, minor: 0, patch: 0, build: 0), true, false, false],
        [Version(major: 0, minor: 0, patch: 0, build: 1), false, true, false],
        [Version(major: 0, minor: 0, patch: 0, build: 2), false, false, true],
      ];

      for (var version in versions) {
        expect((version[0] as Version) < baseVersion, version[1]);
        expect((version[0] as Version) == baseVersion, version[2]);
        expect((version[0] as Version) > baseVersion, version[3]);
      }
    });
  });
}
