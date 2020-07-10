import "package:youtube_explode_dart/youtube_explode_dart.dart";

import "package:Music/models/models.dart";

/// getYoutubeId()
///
/// @param {string} query The title of the video to search on youtube's API
///
/// Returns the first result's youtube id from a search query
Future<YoutubeDetails> getYoutubeDetails(String title, String artist) async {
  try {
    var query = "$title $artist official music video";
    var yt = YoutubeExplode();
    var res = await yt.search.getVideosAsync(query).first;
    yt.close();
    return YoutubeDetails(
      id: res.id.value,
      length: res.duration.inSeconds,
    );
  } catch (err) {
    print(err);
    return null;
  }
}
