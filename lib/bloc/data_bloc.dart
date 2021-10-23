import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music/notifications.dart';
import 'package:music/global_providers/database.dart';
import 'package:music/models/models.dart';
import 'package:music/helpers/downloader.dart';
import 'package:music/helpers/youtube.dart' as yt;
import 'package:music/helpers/updateAlbum.dart';
import 'package:music/helpers/version.dart';

part 'data_event.dart';
part 'data_state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final DatabaseFunctions db;
  final NotificationHandler notificationHandler;
  final Updater updater;
  Timer timer;

  DataBloc({DatabaseFunctions database, this.notificationHandler, this.updater})
      : db = database,
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

        List<YoutubeSongData> ytDetailsArr = [];
        YoutubeSongData ytDetails;
        String albumId, thumbnailFile;

        if (songData is NapsterSongData) {
          ytDetailsArr = await yt.getSearchResults(
              '${songData.title} by ${songData.artist} official music video');

          if (ytDetailsArr == null) throw 'Failed to get Youtube Id';

          ytDetails = ytDetailsArr.removeAt(0);
          albumId = songData.albumId;
          thumbnailFile = '$albumId.jpg';

          await downloadNapsterImage(albumId);
        } else if (songData is YoutubeSongData) {
          ytDetails = songData;
          albumId = 'ytb';
          thumbnailFile = '${songData.id}.jpg';

          await downloadYoutubeImage(songData);
        }

        var filename = songData.title + '.mp3';

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

            song = SongData(
              albumId: albumId,
              artist: songData.artist,
              filePath: '${root.path}/songs/$filename',
              length: length,
              liked: false,
              numListens: 0,
              thumbnail: '${root.path}/album_images/$thumbnailFile',
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
        await updateAlbum(albumId, songData.artist, db);

        await db.insertSong(song);

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

      print('ADDED ${event.name}');
    } else if (event is EditCustomAlbum) {
      var data = {'songs': stringifyArr(event.songs)};

      await db.update(
        Tables.CustomAlbums,
        data,
        where: 'id LIKE ?',
        whereArgs: [event.id],
      );

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
    } else if (event is DeleteCustomAlbum) {
      await db.deleteCustomAlbum(event.id);

      print('DELETED ${event.id}');
    }

    yield UpdateData();
  }
}
