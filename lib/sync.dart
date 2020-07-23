import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

import 'package:Music/connected.dart';
import 'package:Music/helpers/downloader.dart';
import 'package:Music/helpers/getYoutubeDetails.dart';
import 'package:Music/models/models.dart';

import './global_providers/database.dart';
import './keys.dart';
import './sync_status.dart';

class FirestoreSync {
  Firestore firestore;
  FirebaseApp app;
  final DatabaseFunctions db;

  Directory _root;

  bool syncing = false;

  int _numFailed = 0;

  FirestoreSync(this.db) {
    connect();
  }

  final _controller = StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get status => _controller.stream;

  VoidCallback onUpdate;

  void dispose() {
    _controller.close();
  }

  Future<void> connect() async {
    _controller.add(SyncInitial());
    await syncKeys.isReady;
    _root = await getApplicationDocumentsDirectory();

    syncing = true;
    app = await FirebaseApp.configure(
      name: 'sync',
      options: FirebaseOptions(
        googleAppID: syncKeys.appId,
        gcmSenderID: syncKeys.appId.split(':')[1],
        apiKey: syncKeys.apiKey,
        projectID: syncKeys.projectId,
        databaseURL: 'https://${syncKeys.projectId}.firebaseio.com',
      ),
    );

    firestore = Firestore(app: app);

    print('Connected to Firestore');

    firestore.collection(SyncTables.Songs).snapshots().listen(_songHandler);
    firestore.collection(SyncTables.Albums).snapshots().listen(_albumHandler);
    firestore
        .collection(SyncTables.CustomAlbums)
        .snapshots()
        .listen(_customAlbumHandler);

    _controller.add(SyncSongsInitial());
    print('Starting songs');
    await _initSongs();
    print('Finished songs');
    _controller.add(SyncAlbumsInitial());
    print('Starting albums');
    await _initAlbums();
    print('Finished albums');
    _controller.add(SyncCustomAlbumsInitial());
    print('Starting customalbums');
    await _initCustomAlbums();
    print('Finished customalbums');

    _controller.add(SyncCleaningUp());
    db.cleanup();
    _controller.add(SyncComplete());

    if (onUpdate != null) onUpdate();
  }

  Future<void> update(
      String table, String id, Map<String, dynamic> data) async {
    if (syncing)
      return firestore.collection(table).document(id).updateData(data);
  }

  Future<void> insert(
      String table, String id, Map<String, dynamic> data) async {
    if (syncing) return firestore.collection(table).document(id).setData(data);
  }

  Future<void> insertSong(SongData song, [String youtubeId = '']) async {
    if (syncing)
      return insert(SyncTables.Songs, song.title, song.toFirebase(youtubeId));
  }

  Future<void> insertAlbum(AlbumData album) async {
    if (syncing) return insert(SyncTables.Albums, album.id, album.toFirebase());
  }

  Future<void> insertCustomAlbum(CustomAlbumData album) async {
    if (syncing)
      return insert(SyncTables.CustomAlbums, album.id, album.toFirebase());
  }

  Future<void> delete(String table, String id) async {
    if (syncing) return firestore.collection(table).document(id).delete();
  }

  Future<void> deleteEmptyAlbums() async {
    if (syncing) {
      var docs = await firestore
          .collection(SyncTables.Albums)
          .where('numSongs', isLessThan: 1)
          .getDocuments();
      await Future.wait(docs.documents.map((d) => d.reference.delete()));
    }
  }

  Future<void> incrementNumListens(SongData song) async {
    if (!syncing) return;
    await firestore
        .collection(SyncTables.Songs)
        .document(song.title)
        .updateData({
      'numListens': FieldValue.increment(1),
    });
  }

  String _getId(Map<String, dynamic> map) => map['id'] ?? map['title'];

  List<List<int>> _diff<T extends DbCollection>(
      List<T> local, List<Map<String, dynamic>> online) {
    List<int> toAdd = [];
    List<int> toDelete = [];
    List<int> toUpdate = [];

    var i = 0, j = 0;

    while (i < local.length && j < online.length) {
      var lId = local[i].getId;
      var oId = _getId(online[j]);

      if (lId == oId) {
        if (local[i].needsUpdate(online[j])) {
          toUpdate.add(j);
        }
        i++;
        j++;
      } else if (lId < oId) {
        toDelete.add(i);
        i++;
      } else {
        toAdd.add(j);
        j++;
      }
    }

    for (; i < local.length; i++) {
      toDelete.add(i);
    }

    for (; j < online.length; j++) {
      toAdd.add(j);
    }

    print('${toAdd.length}, ${toDelete.length}, ${toUpdate.length}');

    return [toAdd, toDelete, toUpdate];
  }

  Future<bool> _addSong(Map<String, dynamic> firestoreSong) async {
    String title = firestoreSong['title'];
    String youtubeId = firestoreSong['youtubeId'];
    try {
      int length = firestoreSong['length'];

      List<YoutubeDetails> backup = [];

      await hasInternetConnection();

      if (youtubeId.length == 0) {
        var ytDetailsArr =
            await getYoutubeDetails(title, firestoreSong['artist']);
        var ytDetails = ytDetailsArr.removeAt(0);
        length = ytDetails.length;
        youtubeId = ytDetails.id;
        backup = ytDetailsArr;
      }

      var progressStream = downloadSong(youtubeId, '$title.mp3',
          backup: backup.map((vid) => vid.id).toList());

      await for (var progress in progressStream) {
        if (progress.first < 0) {
          var idx = progress.second;

          if (idx >= 0) {
            length = backup[idx].length;
          }
        } else {
          _controller.add(SyncSongsProgress(
              progress.first, progress.second, title, _numFailed));
        }
      }

      var song = SongData.fromFirestore(firestoreSong, length, _root.path);

      await db.insertSong(song);
      return true;
    } catch (e) {
      print('Failed $title; id: $youtubeId');
      print(e);
      _numFailed++;
      return false;
    }
  }

  Future<void> _deleteSong(String title) async {
    var file = File('${_root.path}/songs/$title.mp3');
    await Future.wait([
      db.deleteSong(title),
      file.exists().then((exists) => exists ? file.delete() : Future.value()),
    ]);
  }

  Map<String, dynamic> _cleanSong(Map<String, dynamic> map) => ({
        'title': map['title'],
        'albumId': map['albumId'],
        'artist': map['artist'],
        'liked': map['liked'] ? 1 : 0, // sqflite doesnt accept boolean values
        'numListens': map['numListens'],
      });

  Future _initSongs() async {
    var snapshot = await firestore.collection(SyncTables.Songs).getDocuments();

    var dbSongs = await db.getSongs();
    var firestoreSongs = snapshot.documents.map((d) => d.data).toList();

    dbSongs.sort((a, b) => (a.getId < b.getId ? -1 : 1));
    firestoreSongs.sort((a, b) => (_getId(a) < _getId(b) ? -1 : 1));

    var diff = _diff(dbSongs, firestoreSongs);

    List<int> failed = [];

    for (var idx in diff[0]) {
      _controller
          .add(SyncSongsName(firestoreSongs[idx]['title'], false, _numFailed));
      var success = await _addSong(firestoreSongs[idx]);
      if (!success) failed.add(idx);
    }
    for (var idx in diff[1]) {
      _controller.add(SyncSongsName(dbSongs[idx].title, true, _numFailed));
      await _deleteSong(dbSongs[idx].title);
    }
    for (var idx in diff[2]) {
      var song = firestoreSongs[idx];
      await db.update(
        Tables.Songs,
        _cleanSong(song),
        where: 'title LIKE ?',
        whereArgs: [song['title']],
      );
    }

    _controller.add(SyncSongsFailed(_numFailed));

    for (var idx in failed) {
      _numFailed--;
      _controller
          .add(SyncSongsName(firestoreSongs[idx]['title'], false, _numFailed));
      await _addSong(firestoreSongs[idx]);
    }
  }

  void _songHandler(QuerySnapshot snapshot) async {
    if (!snapshot.metadata.hasPendingWrites &&
        snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        switch (change.type) {
          case DocumentChangeType.added:
            await _addSong(change.document.data);
            break;
          case DocumentChangeType.modified:
            await db.update(
              Tables.Songs,
              _cleanSong(change.document.data),
              where: 'title LIKE ?',
              whereArgs: [change.document.documentID],
            );
            break;
          case DocumentChangeType.removed:
            await _deleteSong(change.document.documentID);
            break;
        }
      });
    }

    if (onUpdate != null) onUpdate();
  }

  Future<void> _addAlbum(Map<String, dynamic> firestoreAlbum) async {
    var album = AlbumData.fromFirebase(firestoreAlbum, _root.path);

    print('Adding album ${album.name}');

    await Future.wait([
      downloadImage(album.id),
      db.insertAlbum(album),
    ]);
  }

  Future _initAlbums() async {
    var snapshot = await firestore.collection(SyncTables.Albums).getDocuments();

    var dbAlbums = await db.getAlbums();
    var firestoreAlbums = snapshot.documents.map((d) => d.data).toList();

    dbAlbums.sort((a, b) => (a.getId < b.getId ? -1 : 1));
    firestoreAlbums.sort((a, b) => (_getId(a) < _getId(b) ? -1 : 1));

    var diff = _diff(dbAlbums, firestoreAlbums);

    await Future.wait(diff[0].map((idx) {
      _controller.add(SyncAlbumsName(firestoreAlbums[idx]['name']));
      return _addAlbum(firestoreAlbums[idx]);
    }));
    await Future.wait(diff[1].map((idx) => db.deleteAlbum(dbAlbums[idx].id)));
    await Future.wait(diff[2].map((idx) {
      var album = firestoreAlbums[idx];
      return db.update(
        Tables.Albums,
        album,
        where: 'id LIKE ?',
        whereArgs: [album['id']],
      );
    }));
  }

  void _albumHandler(QuerySnapshot snapshot) async {
    if (!snapshot.metadata.hasPendingWrites &&
        snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        switch (change.type) {
          case DocumentChangeType.added:
            await _addAlbum(change.document.data);
            break;
          case DocumentChangeType.modified:
            await db.update(
              Tables.Albums,
              change.document.data,
              where: 'id LIKE ?',
              whereArgs: [change.document.documentID],
            );
            break;
          case DocumentChangeType.removed:
            await db.deleteAlbum(change.document.documentID);
            break;
        }
      });
    }

    if (onUpdate != null) onUpdate();
  }

  Future _initCustomAlbums() async {
    var snapshot =
        await firestore.collection(SyncTables.CustomAlbums).getDocuments();

    var dbAlbums = await db.getCustomAlbums();
    var firestoreAlbums = snapshot.documents.map((d) => d.data).toList();

    dbAlbums.sort((a, b) => (a.getId < b.getId ? -1 : 1));
    firestoreAlbums.sort((a, b) => (_getId(a) < _getId(b) ? -1 : 1));

    var diff = _diff(dbAlbums, firestoreAlbums);

    await Future.wait(diff[0].map((idx) {
      var name = firestoreAlbums[idx]['name'];
      _controller.add(SyncCustomAlbumsName(name));
      var album = CustomAlbumData.fromFirebase(firestoreAlbums[idx]);

      return db.insertCustomAlbum(album);
    }));
    await Future.wait(
        diff[1].map((idx) => db.deleteCustomAlbum(dbAlbums[idx].id)));
    await Future.wait(diff[2].map((idx) {
      var album = firestoreAlbums[idx];
      album['songs'] = stringifyArr(album['songs']);
      return db.update(Tables.CustomAlbums, album,
          where: 'id LIKE ?', whereArgs: [album['id']]);
    }));
  }

  void _customAlbumHandler(QuerySnapshot snapshot) async {
    if (!snapshot.metadata.hasPendingWrites &&
        snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        switch (change.type) {
          case DocumentChangeType.added:
            await db.insertCustomAlbum(
                CustomAlbumData.fromFirebase(change.document.data));
            break;
          case DocumentChangeType.modified:
            await db.update(
              Tables.CustomAlbums,
              change.document.data,
              where: 'id LIKE ?',
              whereArgs: [change.document.documentID],
            );
            break;
          case DocumentChangeType.removed:
            await db.deleteCustomAlbum(change.document.documentID);
            break;
        }
      });
    }
    if (onUpdate != null) onUpdate();
  }
}

extension on String {
  bool operator <(String other) {
    var i = 0;
    while (i < length && i < other.length) {
      if (codeUnitAt(i) != other.codeUnitAt(i)) {
        return codeUnitAt(i) < other.codeUnitAt(i);
      }
      i++;
    }

    return length < other.length;
  }
}

abstract class SyncTables {
  static const Songs = 'songs';
  static const Albums = 'albums';
  static const CustomAlbums = 'customalbums';
}
