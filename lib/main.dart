import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "./bloc/data_bloc.dart";
import "./bloc/queue_bloc.dart";
import "./routing.dart";
import "./themedata.dart";
import "./notifications.dart";
import "./sync.dart";
import "./global_providers/database.dart";
import "./global_providers/audio_player.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    print("READY");
    runApp(App());
  });
}

class App extends StatelessWidget {
  final db = DatabaseFunctions();
  final audioPlayer = AudioPlayer();
  final notificationHandler = NotificationHandler();
  final firstoreSync = FirestoreSync();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DataBloc>(
          create: (_) => DataBloc(db, notificationHandler),
        ),
        BlocProvider<QueueBloc>(
          create: (_) => QueueBloc(db, audioPlayer),
        ),
      ],
      child: DatabaseProvider(
        database: db,
        child: AudioPlayerProvider(
          player: audioPlayer,
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // Close keyboard if list is scrolled
              FocusScope.of(notification.context).unfocus();
              return true;
            },
            child: MaterialApp(
              title: "Music",
              theme: themeData,
              darkTheme: themeData,
              initialRoute: "/",
              onGenerateRoute: Router.generateRoute,
              themeMode: ThemeMode.dark,
            ),
          ),
        ),
      ),
    );
  }
}
