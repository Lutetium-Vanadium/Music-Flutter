import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:music/models/models.dart';

/// getSearchResults()
///
/// @param {string} query The title of the video to search on youtube's API
///
/// Returns the first result's youtube id from a search query
Future<List<YoutubeSongData>> getSearchResults(String query) async {
  try {
    var yt = YoutubeExplode();

    var searchList = await yt.search.getVideos(query);

    yt.close();
    return searchList
        .sublist(0, 5)
        .map((vid) => YoutubeSongData(
              id: vid.id.value,
              length: vid.duration.inSeconds,
              title: vid.title,
              artist: 'Unknown',
              thumbnail: vid.thumbnails.mediumResUrl,
            ))
        .toList();
  } catch (err) {
    print(err);
    return null;
  }
}
