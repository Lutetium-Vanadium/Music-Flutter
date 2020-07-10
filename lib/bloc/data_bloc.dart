import "dart:async";
import "dart:io";
import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";
import "package:path_provider/path_provider.dart";

import "package:Music/sync.dart";
import "package:Music/notifications.dart";
import "package:Music/global_providers/database.dart";
import "package:Music/models/models.dart";
import "package:Music/helpers/downloader.dart";
import "package:Music/helpers/getYoutubeDetails.dart";
import "package:Music/helpers/updateAlbum.dart";

part "data_event.dart";
part "data_state.dart";

class DataBloc extends Bloc<DataEvent, DataState> {
  final DatabaseFunctions db;
  final NotificationHandler notificationHandler;
  final FirestoreSync syncDb;

  DataBloc(
      {DatabaseFunctions database,
      this.notificationHandler,
      FirestoreSync syncDatabase})
      : db = database,
        syncDb = syncDatabase,
        super(InitialData());

  @override
  Stream<DataState> mapEventToState(
    DataEvent event,
  ) async* {
    if (event is DownloadSong) {
      var songData = event.song;

      var ytDetails = await getYoutubeDetails(songData.title, songData.artist);

      if (ytDetails == null) return;

      var filename = songData.title + ".mp3";
      var albumId = songData.albumId;

      print("Downloading ${songData.title}");
      var updateAlbumFuture = updateAlbum(albumId, songData.artist, db, syncDb);

      var root = await getApplicationDocumentsDirectory();

      var song = SongData(
        albumId: albumId,
        artist: songData.artist,
        filePath: "${root.path}/songs/$filename",
        length: ytDetails.length,
        liked: false,
        numListens: 0,
        thumbnail: "${root.path}/album_images/$albumId.jpg",
        title: songData.title,
      );

      await Future.wait([
        db.insertSong(song),
        syncDb.insertSong(song, ytDetails.id),
      ]);

      await updateAlbumFuture;
      var progressStream = downloadSong(ytDetails.id, filename);

      final body = "\nDownloading ${song.title} by ${song.artist}";

      await for (var progress in progressStream) {
        notificationHandler.showProgressNotification(
          progress.first,
          progress.second,
          title: song.title,
          body: body,
          path: song.thumbnail,
        );
        yield ProgressNotification(
          bytesDownloaded: progress.first,
          totalBytes: progress.second,
          title: song.title,
        );
      }

      print("Downloaded");
      notificationHandler.showNotification(
        title: song.title,
        body: "Finished Downloading ${song.title} by ${song.artist}",
        path: song.thumbnail,
      );
    } else if (event is DeleteSong) {
      var songFile = File(event.song.filePath);

      var data = {"numSongs": await db.getNumSongs(event.song.albumId)};

      Future.wait([
        songFile.delete(),
        db.deleteSong(event.song.title),
        syncDb.delete(SyncTables.Songs, event.song.title),
        db.update(
          Tables.Albums,
          data,
          where: "id LIKE ?",
          whereArgs: [event.song.albumId],
        ),
        syncDb.update(SyncTables.Albums, event.song.albumId, data),
      ]);

      await db.deleteEmptyAlbums();
    } else if (event is AddCustomAlbum) {
      var album = CustomAlbumData(
        id: await db.nextCustomAlbumId(),
        name: event.name,
        songs: event.songs,
      );

      await Future.wait([
        db.insertCustomAlbum(album),
        syncDb.insertCustomAlbum(album),
      ]);

      print("ADDED ${event.name}");
    } else if (event is EditCustomAlbum) {
      var data = {"songs": stringifyArr(event.songs)};

      await Future.wait([
        db.update(
          Tables.CustomAlbums,
          data,
          where: "id LIKE ?",
          whereArgs: [event.id],
        ),
        syncDb.update(SyncTables.CustomAlbums, event.id, data),
      ]);

      print("UPDATED ${event.id}");
    } else if (event is AddSongToCustomAlbum) {
      var album = (await db.getCustomAlbums(
        where: "id LIKE ?",
        whereArgs: [event.id],
      ))[0];

      if (album.songs.contains(event.song.title)) return;

      album.songs.add(event.song.title);

      await Future.wait([
        db.update(
          Tables.CustomAlbums,
          album.toMap(),
          where: "id LIKE ?",
          whereArgs: [event.id],
        ),
        syncDb.update(SyncTables.CustomAlbums, event.id, album.toFirebase()),
      ]);
    } else if (event is DeleteCustomAlbum) {
      await Future.wait([
        db.deleteCustomAlbum(event.id),
        syncDb.delete(SyncTables.CustomAlbums, event.id),
      ]);

      print("DELETED ${event.id}");
    }

    yield UpdateData();
  }
}
