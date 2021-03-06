import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music/sync.dart';
import 'package:music/notifications.dart';
import 'package:music/global_providers/database.dart';
import 'package:music/models/models.dart';
import 'package:music/helpers/downloader.dart';
import 'package:music/helpers/getYoutubeDetails.dart';
import 'package:music/helpers/updateAlbum.dart';
import 'package:music/helpers/version.dart';

part 'data_event.dart';
part 'data_state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final DatabaseFunctions db;
  final NotificationHandler notificationHandler;
  final FirestoreSync syncDb;
  final Updater updater;
  Timer timer;

  DataBloc(
      {DatabaseFunctions database,
      this.notificationHandler,
      FirestoreSync syncDatabase,
      this.updater})
      : db = database,
        syncDb = syncDatabase,
        super(InitialData()) {
    this.updater.init();
    this.checkForUpdate();

    this.timer = Timer.periodic(Duration(hours: 2), (_) {
      this.checkForUpdate();
    });
  }

  void checkForUpdate() async {
    var version = await updater.checkForUpdate();

    if (version != null) {
      notificationHandler.showNotification(
          title: 'Update available',
          body:
              'Visit https://github.com/Lutetium-Vanadium/Music-Flutter/releases/$version for more information');
    }
  }

  @override
  Stream<DataState> mapEventToState(
    DataEvent event,
  ) async* {
    if (event is DownloadSong) {
      try {
        var songData = event.song;

        var ytDetailsArr =
            await getYoutubeDetails(songData.title, songData.artist);

        if (ytDetailsArr == null) throw 'Failed to get Youtube Id';

        var ytDetails = ytDetailsArr.removeAt(0);
        var youtubeId = ytDetails.id;

        var filename = songData.title + '.mp3';
        var albumId = songData.albumId;

        await downloadImage(albumId);

        print('Downloading ${songData.title}');
        var root = await getApplicationDocumentsDirectory();

        var progressStream = downloadSong(ytDetails.id, filename,
            backup: ytDetailsArr.map((song) => song.id).toList());

        SongData song;

        final body = '\nDownloading ${songData.title} by ${songData.artist}';

        await for (var progress in progressStream) {
          if (progress.first < 0) {
            var idx = progress.second;

            var length = idx < 0 ? ytDetails.length : ytDetailsArr[idx].length;

            if (idx >= 0) {
              youtubeId = ytDetailsArr[idx].id;
            }

            song = SongData(
              albumId: albumId,
              artist: songData.artist,
              filePath: '${root.path}/songs/$filename',
              length: length,
              liked: false,
              numListens: 0,
              thumbnail: '${root.path}/album_images/$albumId.jpg',
              title: songData.title,
            );
          } else {
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
              id: song.title + song.albumId,
            );
          }
        }

        print('Downloaded ${song.title}');
        await updateAlbum(albumId, songData.artist, db, syncDb);

        await db.insertSong(song);
        syncDb.insertSong(song, youtubeId);

        notificationHandler.showNotification(
          title: song.title,
          body: 'Finished Downloading ${song.title} by ${song.artist}',
          path: song.thumbnail,
        );
      } catch (e) {
        notificationHandler.showNotification(
          title: event.song.title,
          body:
              'Failed to download ${event.song.title} by ${event.song.artist}',
        );
        print(e);
      }
    } else if (event is AddCustomAlbum) {
      var album = CustomAlbumData(
        id: await db.nextCustomAlbumId(),
        name: event.name,
        songs: event.songs,
      );

      await db.insertCustomAlbum(album);
      syncDb.insertCustomAlbum(album);

      print('ADDED ${event.name}');
    } else if (event is EditCustomAlbum) {
      var data = {'songs': stringifyArr(event.songs)};

      await db.update(
        Tables.CustomAlbums,
        data,
        where: 'id LIKE ?',
        whereArgs: [event.id],
      );
      syncDb.update(SyncTables.CustomAlbums, event.id, data);

      print('UPDATED ${event.id}');
    } else if (event is AddSongToCustomAlbum) {
      var album = (await db.getCustomAlbums(
        where: 'id LIKE ?',
        whereArgs: [event.id],
      ))[0];

      if (album.songs.contains(event.song.title)) return;

      album.songs.add(event.song.title);

      await db.update(
        Tables.CustomAlbums,
        album.toMap(),
        where: 'id LIKE ?',
        whereArgs: [event.id],
      );
      syncDb.update(SyncTables.CustomAlbums, event.id, album.toFirebase());
    } else if (event is DeleteCustomAlbum) {
      await db.deleteCustomAlbum(event.id);
      syncDb.delete(SyncTables.CustomAlbums, event.id);

      print('DELETED ${event.id}');
    }

    yield UpdateData();
  }
}
