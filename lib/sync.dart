import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";

import "./keys.dart";

class FirestoreSync {
  Firestore firestore;
  FirebaseApp app;

  bool syncing = false;

  FirestoreSync() {
    connect();
  }

  Future<void> connect() async {
    await syncKeys.isReady;

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
    // var snapshots = await firestore.collection("songs").getDocuments();
    // print(snapshots.documents.length);
    // print(snapshots.documents.first);
  }
}
