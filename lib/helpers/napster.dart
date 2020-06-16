import 'dart:convert';
import "package:http/http.dart" as http;

import "./generateUri.dart";
import "../apiKeys.dart";
import "../dataClasses.dart";

const SEARCH_LIMIT = "15";

/// getAlbumInfo()
///
/// @param {string} albumId The id of the album
///
/// Gets the info for an album
Future<NapsterAlbumData> getAlbumInfo(String albumId) async {
  try {
    var response = await http
        .get(generateUri("https://api.napster.com/v2.2/albums/$albumId", {
      "apikey": NAPSTER_API_KEY,
    }));

    if (response.statusCode != 200) throw response.headers["status"];

    return formatAlbumData(jsonDecode(response.body)["albums"][0]);
  } catch (error) {
    print(error);
    return null;
  }
}

/// getSongInfo()
///
/// @param {string} query The search term
///
/// Gets the info for only one particular song
Future<NapsterSongData> getSongInfo(String query) async {
  try {
    var response =
        await http.get(generateUri("https://api.napster.com/v2.2/search", {
      "apikey": NAPSTER_API_KEY,
      "type": "track",
      "per_type_limit": "1",
      "query": query,
    }));
    if (response.statusCode != 200) throw response.headers["status"];

    var track = jsonDecode(response.body)["search"]["data"]["tracks"][0];

    return formatTrackData(track);
  } catch (error) {
    print(error);
    return null;
  }
}

/// search()
///
/// @param {string} query The search query
///
/// Returns the top 10 songs which fit the query
Future<List<NapsterSongData>> search(String query) async {
  try {
    var response =
        await http.get(generateUri("https://api.napster.com/v2.2/search", {
      "apikey": NAPSTER_API_KEY,
      "type": "track",
      "per_type_limit": SEARCH_LIMIT,
      "query": query,
    }));

    if (response.statusCode != 200) throw response.headers["status"];

    var songs = <NapsterSongData>[];

    jsonDecode(response.body)["search"]["data"]["tracks"].forEach((track) {
      songs.add(formatTrackData(track));
    });

    return songs;
  } catch (error) {
    print(error);
    return null;
  }
}

/// formatAlbumData()
///
/// @param data The album object returned by napster api
///
/// Returns the id and name for the album object
NapsterAlbumData formatAlbumData(Map<String, dynamic> data) => NapsterAlbumData(
      id: data["id"],
      name: data["name"],
    );

/// formatTrackData()
///
/// @param track track The track object given by the napster api
///
/// Returns the song details required from the track data
NapsterSongData formatTrackData(Map<String, dynamic> track) => NapsterSongData(
      artist: track["artistName"],
      title: track["name"],
      length: track["playbackSeconds"],
      thumbnail:
          "https://api.napster.com/imageserver/v2/albums/${track["albumId"]}/images/200x200.jpg",
      albumId: track["albumId"],
    );
