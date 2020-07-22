import 'package:Music/models/album_data.dart';
import 'package:Music/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:Music/sync.dart';
import 'package:Music/notifications.dart';
import 'package:Music/global_providers/database.dart';
import 'package:Music/global_providers/audio_player.dart';
import 'package:Music/models/song_data.dart';
import 'package:Music/bloc/data_bloc.dart';
import 'package:Music/bloc/queue_bloc.dart';

class MockDatabaseFunctions extends Mock implements DatabaseFunctions {}

class MockNotificationHandler extends Mock implements NotificationHandler {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockFirestoreSync extends Mock implements FirestoreSync {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Data Bloc', () {
    DataBloc bloc;
    MockDatabaseFunctions db;
    MockNotificationHandler nf;
    MockFirestoreSync fs;

    final mockAlbum = CustomAlbumData(id: 'id', name: 'n', songs: []);

    setUp(() {
      db = MockDatabaseFunctions();
      nf = MockNotificationHandler();
      fs = MockFirestoreSync();

      bloc = DataBloc(database: db, notificationHandler: nf, syncDatabase: fs);
    });

    tearDown(() {
      bloc?.close();
    });

    test('Custom Album added properly', () async {
      when(db.nextCustomAlbumId()).thenAnswer((_) => Future.value('id'));
      when(db.insertCustomAlbum(
        captureAny,
      )).thenAnswer((invocation) {
        expect(invocation.positionalArguments.last, mockAlbum);
        return Future.value();
      });
      when(fs.insertCustomAlbum(
        captureAny,
      )).thenAnswer((invocation) {
        expect(invocation.positionalArguments.last, mockAlbum);
        return Future.value();
      });
      bloc.add(AddCustomAlbum(name: 'n', songs: []));
    });
    test('Custom Album Edited properly', () async {
      bloc.add(EditCustomAlbum(id: 'id', songs: ['song1', 'song2']));

      when(db.update(
        Tables.CustomAlbums,
        captureAny,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((invocation) {
        expect(
          invocation.positionalArguments.last,
          {'songs': '"song1","song2"'},
        );
        return Future.value();
      });
      when(fs.update(
        SyncTables.CustomAlbums,
        captureAny,
        captureAny,
      )).thenAnswer((invocation) {
        expect(
          invocation.positionalArguments.last,
          {'songs': '"song1","song2"'},
        );
        return Future.value();
      });
    });
    test('Custom Album Edited properly', () async {
      when(db.getCustomAlbums(
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([mockAlbum]));

      bloc.add(AddSongToCustomAlbum(id: 'id', song: SongData(title: 'song')));

      when(db.update(
        Tables.CustomAlbums,
        captureAny,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((invocation) {
        expect(
          invocation.positionalArguments.last,
          {
            'id': 'id',
            'name': 'n',
            'songs': '"song"',
          },
        );
        return Future.value();
      });
      when(fs.update(
        SyncTables.CustomAlbums,
        captureAny,
        captureAny,
      )).thenAnswer((invocation) {
        expect(
          invocation.positionalArguments.last,
          {
            'id': 'id',
            'name': 'n',
            'songs': ['song'],
          },
        );
        return Future.value();
      });
    });

    test('Closes without event', () {
      expectLater(bloc, emitsInOrder([isA<InitialData>(), emitsDone]));
      bloc.close();
    });
  });

  group('Queue Bloc', () {
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
    final mockAlbum = AlbumData(
      artist: 'A',
      id: 'id',
      imagePath: 'i',
      name: 'n',
      numSongs: 5,
    );

    QueueBloc bloc;
    MockDatabaseFunctions db;
    MockAudioPlayer ap;
    MockFirestoreSync fs;

    setUp(() {
      db = MockDatabaseFunctions();
      ap = MockAudioPlayer();
      fs = MockFirestoreSync();
      when(db.getAlbums(
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([mockAlbum]));
      when(db.update(
        Tables.Songs,
        captureAny,
        where: captureAnyNamed('where'),
        whereArgs: captureAnyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value());
      when(fs.update(
        SyncTables.Songs,
        captureAny,
        captureAny,
      )).thenAnswer((_) => Future.value());

      bloc = QueueBloc(database: db, audioPlayer: ap, syncDatabase: fs);
    });

    tearDown(() {
      bloc?.close();
    });

    test('Closes without event', () {
      expectLater(bloc, emitsInOrder([EmptyQueue(), emitsDone]));
      bloc.close();
    });
    test('Queues songs', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: mockSongs, index: 0),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: mockSongs));
    });
    test('Queues songs with shuffle', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: [mockSongs[0]], index: 0, shuffled: true),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: [mockSongs[0]], shuffle: true));
    });

    test('ToggleLike updates data', () {
      final expectedResponse = [
        EmptyQueue(),
        EmptyQueue(updateData: true),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(ToggleLikedSong(mockSongs[0]));
    });

    test('Dequeues songs', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: mockSongs, index: 0),
        EmptyQueue(),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: mockSongs));
      bloc.add(DequeueSongs());
    });

    test('Jumps to Song', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: mockSongs, index: 0),
        PlayingQueue(songs: mockSongs, index: 3),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: mockSongs));
      bloc.add(JumpToSong(3));
    });

    test('Goes to next song', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: mockSongs, index: 0),
        PlayingQueue(songs: mockSongs, index: 1),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: mockSongs));
      bloc.add(NextSong());
    });
    test('Wraps on next song', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: mockSongs, index: mockSongs.length - 1),
        PlayingQueue(songs: mockSongs, index: 0),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: mockSongs, index: mockSongs.length - 1));
      bloc.add(NextSong());
    });

    test('Goes to prev song', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: mockSongs, index: 1),
        PlayingQueue(songs: mockSongs, index: 0),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: mockSongs, index: 1));
      bloc.add(PrevSong());
    });
    test('Wraps on prev song', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: mockSongs, index: 0),
        PlayingQueue(songs: mockSongs, index: mockSongs.length - 1),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: mockSongs));
      bloc.add(PrevSong());
    });

    test('Shuffles songs', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: [mockSongs[0]], index: 0),
        PlayingQueue(songs: [mockSongs[0]], index: 0, shuffled: true),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: [mockSongs[0]]));
      bloc.add(ShuffleSongs());
    });

    test('Loops songs', () {
      final expectedResponse = [
        EmptyQueue(),
        PlayingQueue(songs: [mockSongs[0]], index: 0),
        PlayingQueue(songs: [mockSongs[0]], index: 0, loop: true),
      ];

      expectLater(bloc, emitsInOrder(expectedResponse));
      bloc.add(EnqueueSongs(songs: [mockSongs[0]]));
      bloc.add(LoopSongs());
    });
  });
}
