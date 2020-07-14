import "package:equatable/equatable.dart";

abstract class SyncStatus extends Equatable {
  const SyncStatus();

  final int progress = 0;
}

class SyncInitial extends SyncStatus {
  @override
  List<Object> get props => [];
}

class SyncSongsInitial extends SyncStatus {
  final int progress = 1;

  @override
  List<Object> get props => [];
}

class SyncSongsName extends SyncStatus {
  final String name;
  final bool delete;
  final int progress = 1;
  final int failed;

  SyncSongsName(this.name, this.delete, this.failed);

  @override
  List<Object> get props => [name, delete, failed];
}

class SyncSongsProgress extends SyncStatus {
  final int bytesDownloaded;
  final int totalBytes;
  final String title;
  final int progress = 1;
  final int failed;

  SyncSongsProgress(
      this.bytesDownloaded, this.totalBytes, this.title, this.failed);

  double get percentage => bytesDownloaded / totalBytes;

  @override
  List<Object> get props => [bytesDownloaded, totalBytes, title, failed];
}

class SyncSongsFailed extends SyncStatus {
  final int failed;

  SyncSongsFailed(this.failed);

  @override
  List<Object> get props => [failed];
}

class SyncAlbumsInitial extends SyncStatus {
  final int progress = 2;

  @override
  List<Object> get props => [];
}

class SyncAlbumsName extends SyncStatus {
  final String name;
  final int progress = 2;

  SyncAlbumsName(this.name);

  @override
  List<Object> get props => [name];
}

class SyncCustomAlbumsInitial extends SyncStatus {
  final int progress = 3;

  @override
  List<Object> get props => [];
}

class SyncCustomAlbumsName extends SyncStatus {
  final String name;
  final int progress = 3;

  SyncCustomAlbumsName(this.name);

  @override
  List<Object> get props => [name];
}

class SyncCleaningUp extends SyncStatus {
  final int progress = 4;

  @override
  List<Object> get props => [];
}

class SyncComplete extends SyncStatus {
  final int progress = 4;

  @override
  List<Object> get props => [];
}
