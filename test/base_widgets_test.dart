import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:focused_menu/focused_menu.dart";

import "package:Music/models/models.dart";
import "package:Music/routes/widgets/SongList.dart";
import "package:Music/routes/widgets/SongView.dart";
import "package:Music/routes/widgets/Mozaic.dart";
import "package:Music/routes/widgets/CoverImage.dart";

void main() {
  group("Mozaic", () {
    testWidgets("Has four images", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Mozaic(["i1", "i2", "i3", "i4"], 200),
      ));

      expect(find.byType(Image), findsNWidgets(4));
    });

    testWidgets("Image has 1/2 width and height", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Mozaic(["i1", "i2", "i3", "i4"], 200),
      ));

      var imgSize = find.byType(Image).evaluate().first.size;

      expect(imgSize.width, 100);
      expect(imgSize.height, 100);
    });
  });
  group("Cover Image", () {
    testWidgets("No focused menu", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CoverImage(
          title: "T",
          subtitle: "S",
          onClick: () {},
          images: ["1", "2", "3", "4"],
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsNothing);
    });
    testWidgets("With focused menu", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CoverImage(
          title: "T",
          subtitle: "S",
          onClick: () {},
          focusedMenuItems: [],
          images: ["1", "2", "3", "4"],
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsOneWidget);
    });

    testWidgets("Uses Image", (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: CoverImage(
        title: "T",
        subtitle: "S",
        onClick: () {},
        image: "I",
      )));

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Mozaic), findsNothing);
    });

    testWidgets("Uses Mozaic", (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: CoverImage(
        title: "T",
        subtitle: "S",
        onClick: () {},
        images: ["1", "2", "3", "4"],
      )));

      expect(find.byType(Image), findsNWidgets(4));
      expect(find.byType(Mozaic), findsOneWidget);
    });
  });

  group("Song View", () {
    var mockSong1 = SongData(
      albumId: "id",
      artist: "A",
      filePath: "f",
      length: 0,
      liked: false,
      numListens: 0,
      thumbnail: "t",
      title: "t",
    );
    var mockSong2 = NapsterSongData(
      albumId: "id",
      artist: "A",
      length: 0,
      thumbnail: "t",
      title: "t",
    );

    var image = Image.file(File("F"));

    testWidgets("Has focused menu", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongView(
          image: image,
          song: mockSong1,
          showFocusedMenuItems: true,
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsOneWidget);
    });
    testWidgets("Shows icon", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongView(
          image: image,
          song: mockSong1,
          showFocusedMenuItems: true,
          iconData: Icons.timer,
        ),
      ));

      expect(find.byType(Icon), findsOneWidget);
    });
    testWidgets("Works with napster song data", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongView(
          image: image,
          song: mockSong2,
          iconData: Icons.timer,
        ),
      ));

      expect(find.byType(Icon), findsOneWidget);
    });
  });

  group("Song List", () {
    var mockSongs = List.generate(
      5,
      (index) => SongData(
        albumId: "id",
        artist: "A",
        filePath: "f",
        length: index,
        liked: false,
        numListens: index,
        thumbnail: "t",
        title: "t",
      ),
    );

    testWidgets("Has correct number of children", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongList(
          songs: mockSongs,
        ),
      ));

      expect(find.byType(SongView, skipOffstage: false), findsNWidgets(5));
    });
    testWidgets("No focused menu", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongList(
          songs: mockSongs,
          showFocusedMenuItems: false,
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsNothing);
    });
  });
}
