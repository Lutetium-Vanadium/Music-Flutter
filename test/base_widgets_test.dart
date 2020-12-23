import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'package:music/sync.dart';
import 'package:music/models/models.dart';
import 'package:music/bloc/queue_bloc.dart';
import 'package:music/global_providers/database.dart';
import 'package:music/global_providers/audio_player.dart';
import 'package:music/routes/widgets/PlayPause.dart';
import 'package:music/routes/widgets/SongList.dart';
import 'package:music/routes/widgets/SongPage.dart';
import 'package:music/routes/widgets/SongView.dart';
import 'package:music/routes/widgets/Mozaic.dart';
import 'package:music/routes/widgets/CoverImage.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockDatabaseFunctions extends Mock implements DatabaseFunctions {}

class MockFirestoreSync extends Mock implements FirestoreSync {}

void main() {
  group('Mozaic', () {
    testWidgets('Has four images', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Mozaic(['i1', 'i2', 'i3', 'i4'], 200),
      ));

      expect(find.byType(Image), findsNWidgets(4));
    });

    testWidgets('Image has 1/2 width and height', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Mozaic(['i1', 'i2', 'i3', 'i4'], 200),
      ));

      var imgSize = find.byType(Image).evaluate().first.size;

      expect(imgSize.width, 100);
      expect(imgSize.height, 100);
    });
  });
  group('Cover Image', () {
    testWidgets('No focused menu', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CoverImage(
          title: 'T',
          subtitle: 'S',
          onClick: () {},
          images: ['1', '2', '3', '4'],
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsNothing);
    });
    testWidgets('With focused menu', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CoverImage(
          title: 'T',
          subtitle: 'S',
          onClick: () {},
          focusedMenuItems: [],
          images: ['1', '2', '3', '4'],
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsOneWidget);
    });

    testWidgets('Uses Image', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: CoverImage(
        title: 'T',
        subtitle: 'S',
        onClick: () {},
        image: 'I',
      )));

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Mozaic), findsNothing);
    });

    testWidgets('Uses Mozaic', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: CoverImage(
        title: 'T',
        subtitle: 'S',
        onClick: () {},
        images: ['1', '2', '3', '4'],
      )));

      expect(find.byType(Image), findsNWidgets(4));
      expect(find.byType(Mozaic), findsOneWidget);
    });
  });
  group('Song View', () {
    var mockSong1 = SongData(
      albumId: 'id',
      artist: 'A',
      filePath: 'f',
      length: 0,
      liked: false,
      numListens: 0,
      thumbnail: 't',
      title: 't',
    );
    var mockSong2 = NapsterSongData(
      albumId: 'id',
      artist: 'A',
      length: 0,
      thumbnail: 't',
      title: 't',
    );

    var image = Image.file(File('F'));

    testWidgets('Has focused menu', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongView(
          image: image,
          song: mockSong1,
          showFocusedMenuItems: true,
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsOneWidget);
    });
    testWidgets('Shows icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongView(
          image: image,
          song: mockSong1,
          showFocusedMenuItems: true,
          icon: Icon(Icons.timer),
        ),
      ));

      expect(find.byType(Icon), findsOneWidget);
    });
    testWidgets('Works with napster song data', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongView(
          image: image,
          song: mockSong2,
          icon: Icon(Icons.timer),
        ),
      ));

      expect(find.byType(Icon), findsOneWidget);
    });
    testWidgets('Renders correct data', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongView(
          image: image,
          song: mockSong2,
          icon: Icon(Icons.timer),
        ),
      ));

      expect(find.text('t'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('0:00'), findsOneWidget);
    });
  });
  group('Song List', () {
    var mockSongs = List.generate(
      5,
      (index) => SongData(
        albumId: 'id',
        artist: 'A',
        filePath: 'f',
        length: index,
        liked: false,
        numListens: index,
        thumbnail: 't',
        title: 't',
      ),
    );

    testWidgets('Has correct number of children', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongList(
          songs: mockSongs,
        ),
      ));

      expect(find.byType(SongView, skipOffstage: false), findsNWidgets(5));
    });
    testWidgets('No focused menu', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SongList(
          songs: mockSongs,
          showFocusedMenuItems: false,
        ),
      ));

      expect(find.byType(FocusedMenuHolder), findsNothing);
    });
    testWidgets('Has correct number of icons', (tester) async {
      var special = Icon(Icons.ac_unit);
      var regular = Icon(Icons.access_alarm);

      await tester.pumpWidget(MaterialApp(
        home: SongList(
          songs: mockSongs,
          getIcon: (index) => index == 2 ? special : regular,
        ),
      ));

      expect(find.byWidget(special, skipOffstage: false), findsOneWidget);
      expect(find.byWidget(regular, skipOffstage: false), findsNWidgets(4));
    });
  });

  group('Song Page', () {
    MockDatabaseFunctions db;
    MockFirestoreSync fs;
    MockAudioPlayer ap;
    QueueBloc bloc;

    final mockAlbum = AlbumData(
      artist: 'a',
      id: 'id',
      imagePath: 'i',
      name: 'n',
      numSongs: 2,
    );

    final mockSongs = List.generate(
      5,
      (index) => SongData(
        albumId: 'id',
        artist: 'A',
        filePath: 'f',
        length: index,
        liked: false,
        numListens: index,
        thumbnail: 't',
        title: 't',
      ),
    );

    setUp(() {
      db = MockDatabaseFunctions();
      ap = MockAudioPlayer();
      fs = MockFirestoreSync();
      bloc = QueueBloc(database: db, audioPlayer: ap, syncDatabase: fs);

      when(db.getAlbums(
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([mockAlbum]));
    });

    tearDown(() {
      bloc?.close();
    });

    testWidgets('Correct Layout', (tester) async {
      var controller = AnimationController(vsync: tester);

      await tester.pumpWidget(BlocProvider(
        create: (_) => bloc,
        child: MaterialApp(
          home: SongPage(
            controller: controller,
            hero: Hero(child: Placeholder(), tag: 'placeholder'),
            songs: mockSongs,
            title: 'T',
            subtitle: 's',
          ),
        ),
      ));

      expect(find.byType(IconButton), findsNWidgets(2));
      expect(find.text('T'), findsNWidgets(2));
      expect(find.text('s'), findsOneWidget);
      expect(find.byType(FlatButton), findsNWidgets(2));
    });
    testWidgets('Has 2 extra icon buttons with CustomAlbum', (tester) async {
      var controller = AnimationController(vsync: tester);

      await tester.pumpWidget(BlocProvider(
        create: (_) =>
            QueueBloc(database: db, audioPlayer: ap, syncDatabase: fs),
        child: MaterialApp(
          home: SongPage(
            controller: controller,
            hero: Hero(child: Placeholder(), tag: 'placeholder'),
            songs: mockSongs,
            title: 'T',
            subtitle: 's',
            customAlbum: CustomAlbumData(),
          ),
        ),
      ));

      expect(find.byType(IconButton), findsNWidgets(4));
    });
  });

  group('Play Pause', () {
    MockAudioPlayer ap;

    setUp(() {
      ap = MockAudioPlayer();
    });

    testWidgets('Plays and Pauses', (tester) async {
      var isPlaying = BehaviorSubject<bool>.seeded(false);

      when(ap.isPlaying).thenAnswer((_) => isPlaying.stream);

      await tester.pumpWidget(MaterialApp(
        home: AudioPlayerProvider(
          player: ap,
          child: Material(child: PlayPause()),
        ),
      ));

      var btn = find.byType(IconButton);

      expect(btn, findsOneWidget);
      await tester.tap(btn);

      expect(verify(ap.togglePlay()).callCount, 1);

      isPlaying.close();
    });
  });
}
