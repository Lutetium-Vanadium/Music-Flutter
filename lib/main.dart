import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import 'bloc/data_bloc.dart';
import "./bloc/queue_bloc.dart";
import "./routing.dart";
import "./themedata.dart";

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
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DataBloc>(
          create: (_) => DataBloc(),
        ),
        BlocProvider<QueueBloc>(
          create: (_) => QueueBloc(),
        ),
      ],
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
    );
  }
}
