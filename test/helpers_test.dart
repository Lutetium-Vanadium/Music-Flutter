import "package:flutter_test/flutter_test.dart";

import "package:Music/models/pair.dart";
import "package:Music/helpers/displace.dart" as displace;
import "package:Music/helpers/formatLength.dart" as formatLength;
import "package:Music/helpers/generateSubtitle.dart" as subtitle;
import "package:Music/helpers/generateUri.dart" as uri;

void main() {
  group("Displace Tests", () {
    var list = List.generate(10, (index) => index);

    test("displace", () {
      expect(displace.displace(list, 4), [4, 5, 6, 7, 8, 9, 0, 1, 2, 3]);
      expect(displace.displace(list, 8), [8, 9, 0, 1, 2, 3, 4, 5, 6, 7]);
      expect(displace.displace(list, 0), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(displace.displace(list, 9), [9, 0, 1, 2, 3, 4, 5, 6, 7, 8]);
    });

    test("displaceWithoutIndex", () {
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

  group("Format Length", () {
    test("formatLength", () {
      expect(formatLength.formatLength(23), "0:23");
      expect(formatLength.formatLength(69), "1:09");
      expect(formatLength.formatLength(176), "2:56");
      expect(formatLength.formatLength(365), "6:05");
      expect(formatLength.formatLength(420), "7:00");
    });

    test("formatTime", () {
      expect(formatLength.formatTime(23, 37), Pair("0:23", "0:37"));
      expect(formatLength.formatTime(69, 200), Pair("1:09", "3:20"));
      expect(formatLength.formatTime(176, 1000), Pair("02:56", "16:40"));
      expect(formatLength.formatTime(365, 600), Pair("06:05", "10:00"));
      expect(formatLength.formatTime(420, 590), Pair("7:00", "9:50"));
    });
  });

  group("Generate Subtitles", () {
    test("No songs and artist", () {
      expect(
        subtitle.generateSubtitle(type: "Album"),
        "Album",
      );
    });
    test("With songs", () {
      expect(
        subtitle.generateSubtitle(type: "Album", numSongs: 45),
        "Album · 45 songs",
      );

      expect(
        subtitle.generateSubtitle(type: "Album", numSongs: 1),
        "Album · 1 song",
      );
    });

    test("With artist", () {
      expect(
        subtitle.generateSubtitle(type: "Album", artist: "Artist"),
        "Album · Artist",
      );
    });
  });

  group("Generate URI", () {
    var base = "http://example.com/";

    test("No params", () {
      expect(uri.generateUri(base).toString(), base);
      expect(uri.generateUri(base, {}).toString(), base);
    });

    test("One param", () {
      expect(uri.generateUri(base, {"hello": "world"}).toString(),
          "$base?hello=world");
    });

    test("Multiple params", () {
      expect(
        uri.generateUri(base, {
          "hello": "world",
          "param2": "value",
        }).toString(),
        "$base?hello=world&param2=value",
      );
      expect(
        uri.generateUri(base, {
          "hello": "world",
          "param3": "value3",
          "param4": "value4",
        }).toString(),
        "$base?hello=world&param3=value3&param4=value4",
      );
    });
  });
}
