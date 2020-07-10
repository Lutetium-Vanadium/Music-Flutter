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

class FirestoreSync {
  Firestore firestore;
  FirebaseApp app;
  final DatabaseFunctions db;

  Directory _root;

  bool syncing = false;

  FirestoreSync(this.db) {
    connect();
  }

  VoidCallback onUpdate;

  Future<void> connect() async {
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

    print((await db.getSongs()).length);

    print("Starting songs");
    await _initSongs();
    print("Finished songs");
    print("Starting albums");
    await _initAlbums();
    print("Finished albums");
    print("Starting customalbums");
    await _initCustomAlbums();
    print("Finished customalbums");

    db.cleanup();

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
    if (syncing) return insert(SyncTables.Albums, album.id, album.toFirebase());
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
    String youtubeId = firestoreSong["youtubeId"];
    int length = firestoreSong["length"];

    if (youtubeId.length == 0) {
      var ytDetails = await getYoutubeDetails(
          firestoreSong["title"], firestoreSong["artist"]);
      length = ytDetails.length;
      youtubeId = ytDetails.id;
    }

    var song = SongData.fromFirestore(firestoreSong, length, _root);
    await Future.wait([
      db.insertSong(song),
      downloadSong(youtubeId, "${song.title}.mp3").toList(),
    ]);
  }

  Future<void> _deleteSong(String title) async {
    await Future.wait([
      db.deleteSong(title),
      File("${_root.path}/songs/$title.mp3").delete(),
    ]);
  }

  void _songHandler(QuerySnapshot snapshot) async {
    if (snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        print(change.document.documentID);
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
      await _addSong(snapshot.documents[idx].data);
    }
    for (var title in diff.second) {
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
    if (snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        print(change.document.documentID);
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
    var snapshot = await firestore.collection(Tables.Albums).getDocuments();

    var dbAlbums = (await db.getAlbums()).map((s) => s.id).toList();
    var firestoreAlbums = snapshot.documents.map((d) => d.documentID).toList();

    var diff = _diff(dbAlbums, firestoreAlbums);

    await Future.wait(
        diff.first.map((idx) => _addAlbum(snapshot.documents[idx].data)));
    await Future.wait(diff.second.map(db.deleteAlbum));
  }

  void _customAlbumHandler(QuerySnapshot snapshot) async {
    if (snapshot.documents.length != snapshot.documentChanges.length) {
      snapshot.documentChanges.forEach((change) async {
        print(change.document.documentID);
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

    await Future.wait(diff.first.map((idx) => db.insertCustomAlbum(
        CustomAlbumData.fromFirebase(snapshot.documents[idx].data))));
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
    }

    return length < other.length;
  }
}

abstract class SyncTables {
  static const Songs = "songs";
  static const Albums = "albums";
  static const CustomAlbums = "customalbums";
}
