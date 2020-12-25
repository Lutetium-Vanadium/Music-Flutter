import 'package:flutter/material.dart';

import 'package:music/sync.dart';

class SyncProvider extends StatefulWidget {
  final FirestoreSync syncDatabase;
  final Widget child;

  const SyncProvider({Key key, this.syncDatabase, this.child})
      : super(key: key);

  @override
  _SyncProviderState createState() => _SyncProviderState();

  static FirestoreSync getSyncDB(BuildContext context) {
    assert(context != null);
    final SyncProvider result =
        context.findAncestorWidgetOfExactType<SyncProvider>();

    if (result != null) return result.syncDatabase;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'SyncProvider.getSyncDB() called with a context that does not contain a SyncProvider.'),
      ErrorDescription(
          'No SyncProvider ancestor could be found starting from the context that was passed to SyncProvider.getDb(). '
          'This usually happens when the context provided is from the same StatefulWidget as that '
          'whose build function actually creates the SyncProvider widget being sought.'),
      context.describeElement('The context used was')
    ]);
  }
}

class _SyncProviderState extends State<SyncProvider> {
  @override
  void dispose() {
    widget.syncDatabase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
