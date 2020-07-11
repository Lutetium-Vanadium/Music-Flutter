import "package:equatable/equatable.dart";

abstract class SyncStatus extends Equatable {
  const SyncStatus();

  final int progress = 1;
}

class SyncInitial extends SyncStatus {
  @override
  List<Object> get props => [];
}

class SyncSongsInitial extends SyncStatus {
  final int progress = 2;

  @override
  List<Object> get props => [];
}

class SyncSongsName extends SyncStatus {
  final String name;
  final bool delete;
  final int progress = 2;

  SyncSongsName(this.name, this.delete);

  @override
  List<Object> get props => [name, delete];
}

class SyncSongsProgress extends SyncStatus {
  final int bytesDownloaded;
  final int totalBytes;
  final String title;
  final int progress = 2;

  SyncSongsProgress(this.bytesDownloaded, this.totalBytes, this.title);

  double get percentage => bytesDownloaded / totalBytes;

  @override
  List<Object> get props => [bytesDownloaded, totalBytes, title];
}

class SyncAlbumsInitial extends SyncStatus {
  final int progress = 3;

  @override
  List<Object> get props => [];
}

class SyncAlbumsName extends SyncStatus {
  final String name;
  final int progress = 3;

  SyncAlbumsName(this.name);

  @override
  List<Object> get props => [name];
}

class SyncCustomAlbumsInitial extends SyncStatus {
  final int progress = 4;

  @override
  List<Object> get props => [];
}

class SyncCustomAlbumsName extends SyncStatus {
  final String name;
  final int progress = 4;

  SyncCustomAlbumsName(this.name);

  @override
  List<Object> get props => [name];
}

class SyncCleaningUp extends SyncStatus {
  final int progress = 5;

  @override
  List<Object> get props => [];
}

class SyncComplete extends SyncStatus {
  final int progress = 5;

  @override
  List<Object> get props => [];
}
