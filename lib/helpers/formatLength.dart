import "../dataClasses.dart";

String formatLength(int length) {
  var mins = (length / 60).toStringAsFixed(0);
  var secs = (length % 60).toString().padLeft(2, "0");

  return "$mins:$secs";
}

Pair<String, String> formatTime(int currentLength, int totalLength) {
  var totMins = (totalLength / 60).toStringAsFixed(0);
  var totSecs = (totalLength % 60).toString().padLeft(2, "0");

  var curMins =
      (currentLength / 60).toStringAsFixed(0).padLeft(totMins.length, "0");
  var curSecs = (currentLength % 60).toString().padLeft(2, "0");

  return Pair("$curMins:$curSecs", "$totMins:$totSecs");
}
