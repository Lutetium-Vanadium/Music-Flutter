import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:Music/models/models.dart';

/// getYoutubeId()
///
/// @param {string} query The title of the video to search on youtube's API
///
/// Returns the first result's youtube id from a search query
Future<List<YoutubeDetails>> getYoutubeDetails(
    String title, String artist) async {
  try {
    var query = '$title by $artist official music video';
    var yt = YoutubeExplode();
    var i = 0;

    var res =
        await yt.search.getVideos(query).takeWhile((_) => i++ < 5).toList();

    yt.close();
    return res
        .map((vid) => YoutubeDetails(
              id: vid.id.value,
              length: vid.duration.inSeconds,
            ))
        .toList();
  } catch (err) {
    print(err);
    return null;
  }
}
