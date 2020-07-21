part of "data_bloc.dart";

// Equatable not used because each UpdateData must be taken as seperate things and not the same

@immutable
abstract class DataState {}

class InitialData extends DataState {}

class ProgressNotification extends DataState {
  final int bytesDownloaded;
  final int totalBytes;
  final String id;
  ProgressNotification({this.id, this.bytesDownloaded, this.totalBytes})
      : super();

  double get percentage => bytesDownloaded / totalBytes;
}

class UpdateData extends DataState {}
