import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import 'package:Music/helpers/db.dart';
import 'package:Music/helpers/downloader.dart';
import 'package:Music/helpers/getYoutubeDetails.dart';
import 'package:Music/helpers/updateAlbum.dart';
import 'package:Music/models/models.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  @override
  NotificationState get initialState => NotificationInitial();

  @override
  Stream<NotificationState> mapEventToState(
    NotificationEvent event,
  ) async* {
    if (event is DownloadSong) {
      var songData = event.song;
      print(songData);

      var data = await getYoutubeDetails(songData);

      if (data == null) return;

      var filename = songData.title + ".mp3";
      var albumId = songData.albumId;

      print("Downloading ${songData.title}");
      var updateAlbumFuture = updateAlbum(albumId, songData.artist);

      var root = await getApplicationDocumentsDirectory();

      var song = Song(
        albumId: albumId,
        artist: songData.artist,
        filePath: "${root.path}/songs/$filename",
        length: data.length,
        liked: false,
        numListens: 0,
        thumbnail: "${root.path}/album_images/$albumId.jpg",
        title: songData.title,
      );

      var db = await getDB();

      await db.insert(Tables.Songs, Song.toMap(song));

      await updateAlbumFuture;
      var progressStream = downloadSong(data.id, filename);

      await for (var progress in progressStream) {
        yield ProgressNotification(
          bytesDownloaded: progress.first,
          totalBytes: progress.second,
        );
      }

      print("Downloaded");

      yield DownloadedNotification();
    }
  }
}
