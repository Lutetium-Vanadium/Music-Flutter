import "./song_data.dart";

class SelectedSongData extends SongData {
  final bool selected;

  SelectedSongData toggleSelected() {
    return SelectedSongData(
      this,
      selected: !selected,
    );
  }

  SelectedSongData(SongData song, {this.selected}) : super.override(song);

  List<Object> get props => [
        title,
        artist,
        albumId,
        filePath,
        numListens,
        liked,
        thumbnail,
        length,
        selected,
      ];
}
