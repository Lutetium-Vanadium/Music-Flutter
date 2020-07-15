import "package:flutter/material.dart";

import "package:Music/global_providers/sync_provider.dart";
import "package:Music/sync_status.dart";
import "package:Music/sync.dart";

class SyncStatusPage extends StatefulWidget {
  @override
  _SyncStatusPageState createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage> {
  FirestoreSync syncDB;

  @override
  void initState() {
    syncDB = SyncProvider.getSyncDB(context);
    syncDB.status.listen((event) {
      if (event is SyncComplete) {
        Navigator.of(context).pop();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Syncing with Firebase",
                  style: Theme.of(context).textTheme.headline4),
              Text(
                "This may take some time",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: StreamBuilder<SyncStatus>(
                  stream: syncDB.status,
                  builder: (context, snapshot) {
                    var progress = 0;
                    int numFailed;
                    Widget widget = Text("Starting Sync...");
                    if (snapshot.hasData) {
                      var event = snapshot.data;
                      progress = event.progress;

                      if (event is SyncSongsInitial) {
                        widget = Text("Checking Songs...");
                      } else if (event is SyncSongsName) {
                        numFailed = event.failed;
                        if (event.delete) {
                          widget = Text("Deleting ${event.name}");
                        } else {
                          widget = Text("Starting download for ${event.name}");
                        }
                      } else if (event is SyncSongsProgress) {
                        numFailed = event.failed;
                        widget = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text("Downloading ${event.title}"),
                            SizedBox(height: 10),
                            LinearProgressIndicator(
                              backgroundColor: Theme.of(context).primaryColor,
                              value: event.percentage,
                              valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).accentColor),
                            ),
                          ],
                        );
                      } else if (event is SyncSongsFailed) {
                        widget = Text(
                            "Retrying ${event.failed} song${event.failed == 1 ? "" : "s"}.");
                      } else if (event is SyncAlbumsInitial) {
                        widget = Text("Checking Albums...");
                      } else if (event is SyncAlbumsName) {
                        widget = Text("Adding ${event.name}");
                      } else if (event is SyncCustomAlbumsInitial) {
                        widget = Text("Checking Custom Albums...");
                      } else if (event is SyncCustomAlbumsName) {
                        widget = Text("Adding ${event.name}");
                      } else if (event is SyncCleaningUp) {
                        widget = Text("Cleaning Up...");
                      }
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          child: LinearProgressIndicator(
                            backgroundColor: Theme.of(context).primaryColor,
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).accentColor),
                            value: progress / 4,
                          ),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          height: 40,
                          child: widget,
                        ),
                        if (numFailed != null) Text("$numFailed songs failed."),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
