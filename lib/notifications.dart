import "package:flutter_local_notifications/flutter_local_notifications.dart";

class NotificationHandler {
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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showProgressNotification(int progress, int maxProgress,
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

  Future<void> showNotification(
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
}
