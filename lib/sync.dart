import "dart:async";
import "dart:io";
import "package:flutter/foundation.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:path_provider/path_provider.dart";

import "package:Music/helpers/downloader.dart";
import "package:Music/helpers/getYoutubeDetails.dart";
import "package:Music/models/models.dart";

import "./global_providers/database.dart";
import "./keys.dart";
import "./sync_status.dart";

class FirestoreSync {
  Firestore firestore;
  FirebaseApp app;
  final DatabaseFunctions db;

  Directory _root;

  bool syncing = false;

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
      name: "sync",
      options: FirebaseOptions(
        googleAppID: syncKeys.appId,
        gcmSenderID: syncKeys.appId.split(":")[1],
        apiKey: syncKeys.apiKey,
        projectID: syncKeys.projectId,
        databaseURL: "https://${syncKeys.projectId}.firebaseio.com",
      ),
    );

    firestore = Firestore(app: app);

    print("Connected to Firestore");

    firestore.collection(SyncTables.Songs).snapshots().listen(_songHandler);
    firestore.collection(SyncTables.Albums).snapshots().listen(_albumHandler);
    firestore
        .collection(SyncTables.CustomAlbums)
        .snapshots()
        .listen(_customAlbumHandler);

    _controller.add(SyncSongsInitial());
    print("Starting songs");
    await _initSongs();
    print("Finished songs");
    _controller.add(SyncAlbumsInitial());
    print("Starting albums");
    await _initAlbums();
    print("Finished albums");
    _controller.add(SyncCustomAlbumsInitial());
    print("Starting customalbums");
    await _initCustomAlbums();
    print("Finished customalbums");

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

  Future<void> insertSong(SongData song, [String youtubeId = ""]) async {
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
          .where("numSongs", isLessThan: 1)
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
      "numListens": FieldValue.increment(1),
    });
  }

  Pair<List<int>, List<String>> _diff(List<String> local, List<String> online) {
    local.sort();
    online.sort();

    List<int> toAdd = [];
    List<String> toDelete = [];
    var i = 0, j = 0;

    while (i < local.length && j < online.length) {
      var lId = local[i];
      var oId = online[j];

      if (lId == oId) {
        i++;
        j++;
      } else if (lId < oId) {
        toDelete.add(lId);
        i++;
      } else {
        toAdd.add(j);
        j++;
      }
    }

    for (; i < local.length; i++) {
      toDelete.add(local[i]);
    }

    for (; j < online.length; j++) {
      toAdd.add(j);
    }

    print("${toAdd.length}, ${toDelete.length}");

    return Pair(toAdd, toDelete);
  }

  Future<void> _addSong(Map<String, dynamic> firestoreSong) async {
    String title = firestoreSong["title"];
    String youtubeId = firestoreSong["youtubeId"];
    try {
      int length = firestoreSong["length"];

      List<YoutubeDetails> backup = [];

      if (youtubeId.length == 0) {
        var ytDetailsArr =
            await getYoutubeDetails(title, firestoreSong["artist"]);
        var ytDetails = ytDetailsArr.removeAt(0);
        length = ytDetails.length;
        youtubeId = ytDetails.id;
        backup = ytDetailsArr;
      }

      var progressStream = downloadSong(youtubeId, "$title.mp3",
          backup: backup.map((vid) => vid.id).toList());

      await for (var progress in progressStream) {
        if (progress.first < 0) {
          var idx = progress.second;

          if (idx > 0) {
            length = backup[idx].length;
          }
        } else {
          _controller
              .add(SyncSongsProgress(progress.first, progress.second, title));
        }
      }

      var song = SongData.fromFirestore(firestoreSong, length, _root);

      await db.insertSong(song);
    } catch (e) {
      print(e);
      print("Failed $title; id: $youtubeId");
    }
  }

  Future<void> _deleteSong(String title) async {
    var file = File("${_root.path}/songs/$title.mp3");
    await Future.wait([
      db.deleteSong(title),
      file.exists().then((exists) => exists ? file.delete() : Future.value()),
    ]);
  }

  void _songHandler(QuerySnapshot snapshot) async {
    if (!snapshot.metadata.hasPendingWrites &&
        snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        print(change.document.data);
        switch (change.type) {
          case DocumentChangeType.added:
            await _addSong(change.document.data);
            break;
          case DocumentChangeType.modified:
            await db.update(
              Tables.Songs,
              change.document.data,
              where: "title LIKE ?",
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

  Future _initSongs() async {
    var snapshot = await firestore.collection(SyncTables.Songs).getDocuments();

    var dbSongs = (await db.getSongs()).map((s) => s.title).toList();
    var firestoreSongs = snapshot.documents.map((d) => d.documentID).toList();

    var diff = _diff(dbSongs, firestoreSongs);

    for (var idx in diff.first) {
      _controller.add(SyncSongsName(snapshot.documents[idx].documentID, false));
      await _addSong(snapshot.documents[idx].data);
    }
    for (var title in diff.second) {
      _controller.add(SyncSongsName(title, true));
      await _deleteSong(title);
    }
  }

  Future<void> _addAlbum(Map<String, dynamic> firestoreAlbum) async {
    var album = AlbumData.fromFirebase(firestoreAlbum, _root);

    print("Adding album ${album.name}");

    await Future.wait([
      downloadImage(album.id),
      db.insertAlbum(album),
    ]);
  }

  void _albumHandler(QuerySnapshot snapshot) async {
    if (!snapshot.metadata.hasPendingWrites &&
        snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        print(change.document.data);
        switch (change.type) {
          case DocumentChangeType.added:
            await _addAlbum(change.document.data);
            break;
          case DocumentChangeType.modified:
            await db.update(
              Tables.Albums,
              change.document.data,
              where: "id LIKE ?",
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

  Future _initAlbums() async {
    var snapshot = await firestore.collection(SyncTables.Albums).getDocuments();

    var dbAlbums = (await db.getAlbums()).map((s) => s.id).toList();
    var firestoreAlbums = snapshot.documents.map((d) => d.documentID).toList();

    var diff = _diff(dbAlbums, firestoreAlbums);

    await Future.wait(diff.first.map((idx) {
      _controller.add(SyncAlbumsName(snapshot.documents[idx].data["name"]));
      return _addAlbum(snapshot.documents[idx].data);
    }));
    await Future.wait(diff.second.map(db.deleteAlbum));
  }

  void _customAlbumHandler(QuerySnapshot snapshot) async {
    if (!snapshot.metadata.hasPendingWrites &&
        snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        print(change.document.data);
        switch (change.type) {
          case DocumentChangeType.added:
            await db.insertCustomAlbum(
                CustomAlbumData.fromFirebase(change.document.data));
            break;
          case DocumentChangeType.modified:
            await db.update(
              Tables.CustomAlbums,
              change.document.data,
              where: "id LIKE ?",
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

  Future _initCustomAlbums() async {
    var snapshot =
        await firestore.collection(Tables.CustomAlbums).getDocuments();

    var dbAlbums = (await db.getCustomAlbums()).map((s) => s.id).toList();
    var firestoreAlbums = snapshot.documents.map((d) => d.documentID).toList();

    var diff = _diff(dbAlbums, firestoreAlbums);

    await Future.wait(diff.first.map((idx) {
      _controller
          .add(SyncCustomAlbumsName(snapshot.documents[idx].data["name"]));
      return db.insertCustomAlbum(
          CustomAlbumData.fromFirebase(snapshot.documents[idx].data));
    }));
    await Future.wait(diff.second.map(db.deleteCustomAlbum));
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
  static const Songs = "songs";
  static const Albums = "albums";
  static const CustomAlbums = "customalbums";
}
