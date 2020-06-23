import "dart:async";
import "package:bloc/bloc.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

import "package:Music/helpers/db.dart";
import "package:Music/helpers/downloader.dart";
import "package:Music/helpers/getYoutubeDetails.dart";
import "package:Music/helpers/updateAlbum.dart";
import "package:Music/models/models.dart";

part "notification_event.dart";
part "notification_state.dart";

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() {
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
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
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

      await db.insert(Tables.Songs, SongData.toMap(song));

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
        );
      }

      print("Downloaded");
      _showNotification(
        title: song.title,
        body: "Finished Downloading ${song.title} by ${song.artist}",
        path: song.thumbnail,
      );

      yield DownloadedNotification();
    }
  }
}
