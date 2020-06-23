import "dart:convert";
import "package:http/http.dart" as http;

import "package:Music/models/models.dart";
import "./generateUri.dart";
import "../apiKeys.dart";

var searchUri = "https://www.googleapis.com/youtube/v3/search";
var detailsUri = "https://www.googleapis.com/youtube/v3/videos";

/// getYoutubeId()
///
/// @param {string} query The title of the video to search on youtube's API
///
/// Returns the first result's youtube id from a search query
Future<YoutubeDetails> getYoutubeDetails(NapsterSongData song) async {
  try {
    // Makes sure to get the right video
    var query = "${song.title} ${song.artist} official music video";

    query = query.replaceAll(" ", "+");

    var result = await http.get(generateUri(searchUri, {
      "key": GOOGLE_API_KEY,
      "q": query,
      "part": "snippet",
    }));

    // var id = result.items[0].id.videoId;
    var id = jsonDecode(result.body)["items"][0]["id"]["videoId"];

    var response = await http.get(generateUri(detailsUri, {
      "key": GOOGLE_API_KEY,
      "part": "contentDetails",
      "id": id,
    }));

    var duration =
        jsonDecode(response.body)["items"][0]["contentDetails"]["duration"];

    return YoutubeDetails(
      id: id,
      length: parseDuration(duration),
    );
  } catch (err) {
    print(err);
    return null;
  }
}

int parseDuration(String dur) {
  var hourMatch = RegExp("[0-9]*H").stringMatch(dur);
  var hours = hourMatch != null
      ? int.parse(hourMatch.substring(0, hourMatch.length - 1))
      : 0;

  var minMatch = RegExp("[0-9]*M").stringMatch(dur);
  var mins = minMatch != null
      ? int.parse(minMatch.substring(0, minMatch.length - 1))
      : 0;

  var secMatch = RegExp("[0-9]*S").stringMatch(dur);
  var secs = secMatch != null
      ? int.parse(secMatch.substring(0, secMatch.length - 1))
      : 0;

  return hours * 3600 + mins * 60 + secs;
}
