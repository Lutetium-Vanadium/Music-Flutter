import "dart:io";

const duration = Duration(milliseconds: 500);

Future<void> hasInternetConnection() async {
  var connected = false;

  while (!connected) {
    try {
      final result = await InternetAddress.lookup("youtube.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        break;
      }
    } on SocketException catch (_) {
      Future.delayed(duration);
    }
  }
}
