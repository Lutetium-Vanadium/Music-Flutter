import "dart:async";
import "dart:io";
import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

import "package:Music/helpers/db.dart";
import "package:Music/helpers/downloader.dart";
import "package:Music/helpers/getYoutubeDetails.dart";
import "package:Music/helpers/updateAlbum.dart";
import "package:Music/models/models.dart";

part "data_event.dart";
part "data_state.dart";

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc() {
    initNotifications();
  }

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  void initNotifications() async {
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var initializationSettingsAndroid =
        AndroidInitializationSettings("app_icon");
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          print(id);
          print(title);
          print(body);
          print(payload);
          // NOTE do something proper here
        });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint("notification payload: " + payload);
      }
    });
  }

  Future<void> _showProgressNotification(int progress, int maxProgress,
      {String title = "Progress", String body = "", String path}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      "progress channel",
      "progress channel",
      "progress channel description",
      channelShowBadge: false,
      importance: Importance.Max,
      priority: Priority.High,
      onlyAlertOnce: true,
      largeIcon: FilePathAndroidBitmap(path),
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
    );

    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      null,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: "item x",
    );
  }

  Future<void> _showNotification(
      {String title, String body, String path}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      "your channel id",
      "your channel name",
      "your channel description",
      importance: Importance.Max,
      largeIcon: FilePathAndroidBitmap(path),
      priority: Priority.High,
      ticker: "ticker",
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: "item x");
  }

  @override
  DataState get initialState => InitialData();

  @override
  Stream<DataState> mapEventToState(
    DataEvent event,
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

      var song = SongData(
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

      await db.insert(Tables.Songs, song.toMap());

      await updateAlbumFuture;
      var progressStream = downloadSong(data.id, filename);

      final body = "\nDownloading ${song.title} by ${song.artist}";

      await for (var progress in progressStream) {
        _showProgressNotification(
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
      _showNotification(
        title: song.title,
        body: "Finished Downloading ${song.title} by ${song.artist}",
        path: song.thumbnail,
      );
    } else if (event is DeleteSong) {
      var songFile = File(event.song.filePath);
      var db = await getDB();

      Future.wait([
        songFile.delete(),
        db.delete(Tables.Songs,
            where: "title LIKE ?", whereArgs: [event.song.title]),
        db.rawUpdate(
            "UPDATE ${Tables.Albums} SET numSongs = numSongs - 1 WHERE id LIKE ?",
            [event.song.albumId]),
      ]);

      await db.delete(Tables.Albums, where: "numSongs < 1");
    } else if (event is EditCustomAlbum) {
      var db = await getDB();

      await db.rawUpdate(
        "UPDATE ${Tables.CustomAlbums} SET songs = ? WHERE id LIKE ?",
        [stringifyArr(event.songs), event.id],
      );

      print("UPDATED ${event.id}");
    } else if (event is AddCustomAlbum) {
      var db = await getDB();

      var ids = await db.query(
        Tables.CustomAlbums,
        orderBy: "id DESC",
      );

      int number = 0;
      if (ids.length > 0) {
        number = int.parse(ids.first["id"].substring(4)) + 1;
      }

      var album = CustomAlbumData(
        id: "cst.$number",
        name: event.name,
        songs: event.songs,
      );

      await db.insert(Tables.CustomAlbums, album.toMap());

      print("ADDED ${event.name}");
    } else if (event is AddSongToCustomAlbum) {
      var db = await getDB();

      var album = CustomAlbumData.fromMapArray(await db.query(
        Tables.CustomAlbums,
        where: "id LIKE ?",
        whereArgs: [event.id],
      ))[0];

      if (album.songs.contains(event.song.title)) return;

      album.songs.add(event.song.title);

      db.update(Tables.CustomAlbums, album.toMap(),
          where: "id LIKE ?", whereArgs: [event.id]);
    } else if (event is DeleteCustomAlbum) {
      var db = await getDB();

      await db.delete(Tables.CustomAlbums,
          where: "id LIKE ?", whereArgs: [event.id]);

      print("DELETED ${event.id}");
    }

    // NOTE ForceUpdate doesnt need to be specially handled since it just requires to yield UpdateData()

    yield UpdateData();
  }
}
