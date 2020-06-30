part of "notification_bloc.dart";

// Equatable not used because each UpdateData must be taken as seperate things and not the same

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class ProgressNotification extends NotificationState {
  final int bytesDownloaded;
  final int totalBytes;
  ProgressNotification({this.bytesDownloaded, this.totalBytes}) : super();
}

class UpdateData extends NotificationState {}
