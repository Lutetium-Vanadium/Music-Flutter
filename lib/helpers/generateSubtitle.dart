import "package:flutter/material.dart";

String generateSubtitle({@required String type, int numSongs, String artist}) {
  assert(numSongs == null || artist == null);

  if (numSongs == null && artist == null) {
    return type;
  }

  if (numSongs != null) {
    return "$type · $numSongs ${numSongs == 1 ? "song" : "songs"}";
  }

  return "$type · $artist";
}
