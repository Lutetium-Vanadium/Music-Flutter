import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/data_bloc.dart';
import './bloc/queue_bloc.dart';
import './routing.dart';
import './themedata.dart';
import './notifications.dart';
import './sync.dart';
import './global_providers/database.dart';
import './global_providers/sync_provider.dart';
import './global_providers/audio_player.dart';
import 'helpers/version.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    print('READY');
    runApp(App(DatabaseFunctions()));
  });
}

class App extends StatelessWidget {
  final DatabaseFunctions db;
  final audioPlayer = AudioPlayer();
  final notificationHandler = NotificationHandler();
  final FirestoreSync firestoreSync;
  final Updater updater;

  App(this.db)
      : firestoreSync = FirestoreSync(db),
        updater = Updater();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DataBloc>(create: (_) {
          var bloc = DataBloc(
            database: db,
            notificationHandler: notificationHandler,
            syncDatabase: firestoreSync,
            updater: updater,
          );
          firestoreSync.onUpdate = () => bloc.add(ForceUpdate());
          return bloc;
        }),
        BlocProvider<QueueBloc>(
          create: (_) => QueueBloc(
            database: db,
            audioPlayer: audioPlayer,
            syncDatabase: firestoreSync,
          ),
        ),
      ],
      child: DatabaseProvider(
        database: db,
        child: AudioPlayerProvider(
          player: audioPlayer,
          child: SyncProvider(
            syncDatabase: firestoreSync,
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                // Close keyboard if list is scrolled
                FocusScope.of(notification.context).unfocus();
                return true;
              },
              child: MaterialApp(
                title: 'Music',
                theme: themeData,
                darkTheme: themeData,
                initialRoute: '/',
                onGenerateRoute: MusicRouter.generateRoute,
                themeMode: ThemeMode.dark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
