import "package:flutter_test/flutter_test.dart";

// import "package:Music/models/song_data.dart";
// import 'package:Music/bloc/data_bloc.dart';
// import "package:Music/bloc/queue_bloc.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // group("Notification Bloc", () {
  //   DataBloc bloc;

  //   setUp(() {
  //     bloc = DataBloc();
  //   });

  //   tearDown(() {
  //     bloc?.close();
  //   });

  //   test("Initial state is correct", () {
  //     expect(bloc.initialState, isA<InitialData>());
  //   });
  //   test("Closes without event", () {
  //     expectLater(bloc, emitsInOrder([isA<InitialData>(), emitsDone]));
  //     bloc.close();
  //   });
  // });

  // group("Queue Bloc", () {
  //   var mockSongs = List.generate(
  //     5,
  //     (index) => SongData(
  //       albumId: "id",
  //       artist: "A",
  //       filePath: "f",
  //       length: index,
  //       liked: false,
  //       numListens: index,
  //       thumbnail: "t",
  //       title: "t",
  //     ),
  //   );
  //   QueueBloc bloc;

  //   setUp(() {
  //     bloc = QueueBloc();
  //   });

  //   tearDown(() {
  //     bloc?.close();
  //   });

  //   test("Initial state is correct", () {
  //     expect(bloc.initialState, EmptyQueue());
  //   });
  //   test("Closes without event", () {
  //     expectLater(bloc, emitsInOrder([EmptyQueue(), emitsDone]));
  //     bloc.close();
  //   });
  //   test("Queues songs", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: mockSongs, index: 0),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: mockSongs));
  //   });
  //   test("Queues songs with shuffle", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: [mockSongs[0]], index: 0, shuffled: true),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: [mockSongs[0]], shuffle: true));
  //   });

  //   test("Dequeues songs", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: mockSongs, index: 0),
  //       EmptyQueue(),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: mockSongs));
  //     bloc.add(DequeueSongs());
  //   });

  //   test("Goes to next song", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: mockSongs, index: 0),
  //       PlayingQueue(songs: mockSongs, index: 1),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: mockSongs));
  //     bloc.add(NextSong());
  //   });
  //   test("Wraps on next song", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: mockSongs, index: mockSongs.length - 1),
  //       PlayingQueue(songs: mockSongs, index: 0),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: mockSongs, index: mockSongs.length - 1));
  //     bloc.add(NextSong());
  //   });

  //   test("Goes to prev song", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: mockSongs, index: 1),
  //       PlayingQueue(songs: mockSongs, index: 0),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: mockSongs, index: 1));
  //     bloc.add(PrevSong());
  //   });
  //   test("Wraps on prev song", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: mockSongs, index: 0),
  //       PlayingQueue(songs: mockSongs, index: mockSongs.length - 1),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: mockSongs));
  //     bloc.add(PrevSong());
  //   });

  //   test("Shuffles songs", () {
  //     final expectedResponse = [
  //       EmptyQueue(),
  //       PlayingQueue(songs: [mockSongs[0]], index: 0),
  //       PlayingQueue(songs: [mockSongs[0]], index: 0, shuffled: true),
  //     ];

  //     expectLater(bloc, emitsInOrder(expectedResponse));
  //     bloc.add(EnqueueSongs(songs: [mockSongs[0]]));
  //     bloc.add(ShuffleSongs());
  //   });
  // });
}
