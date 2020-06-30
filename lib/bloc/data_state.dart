part of 'data_bloc.dart';

// Equatable not used because each UpdateData must be taken as seperate things and not the same

@immutable
abstract class DataState {}

class InitialData extends DataState {}

class ProgressNotification extends DataState {
  final int bytesDownloaded;
  final int totalBytes;
  ProgressNotification({this.bytesDownloaded, this.totalBytes}) : super();
}

class UpdateData extends DataState {}
