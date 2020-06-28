import "package:flutter_test/flutter_test.dart";

import "package:Music/models/models.dart";

void main() {
  group("Song Data", () {
    test("from map", () {
      expect(
        SongData.fromMap({
          "albumId": "albumId",
          "artist": "artist",
          "filePath": "/file/path",
          "length": 10,
          "liked": 1,
          "numListens": 10,
          "thumbnail": "thumbnail.png",
          "title": "title",
        }),
        SongData(
          albumId: "albumId",
          artist: "artist",
          filePath: "/file/path",
          length: 10,
          liked: true,
          numListens: 10,
          thumbnail: "thumbnail.png",
          title: "title",
        ),
      );
    });
    test("from map array", () {
      expect(
        SongData.fromMapArray(
          List.generate(
            10,
            (index) => {
              "albumId": "albumId",
              "artist": "artist",
              "filePath": "/file/path",
              "length": index,
              "liked": 1,
              "numListens": index,
              "thumbnail": "thumbnail.png",
              "title": "title",
            },
          ),
        ),
        List.generate(
          10,
          (index) => SongData(
            albumId: "albumId",
            artist: "artist",
            filePath: "/file/path",
            length: index,
            liked: true,
            numListens: index,
            thumbnail: "thumbnail.png",
            title: "title",
          ),
        ),
      );
    });
    test("to map", () {
      expect(
        SongData.toMap(SongData(
          albumId: "albumId",
          artist: "artist",
          filePath: "/file/path",
          length: 10,
          liked: true,
          numListens: 10,
          thumbnail: "thumbnail.png",
          title: "title",
        )),
        {
          "albumId": "albumId",
          "artist": "artist",
          "filePath": "/file/path",
          "length": 10,
          "liked": 1,
          "numListens": 10,
          "thumbnail": "thumbnail.png",
          "title": "title",
        },
      );
    });
    test("to map array", () {
      expect(
        SongData.toMapArray(
          List.generate(
            10,
            (index) => SongData(
              albumId: "albumId",
              artist: "artist",
              filePath: "/file/path",
              length: index,
              liked: true,
              numListens: index,
              thumbnail: "thumbnail.png",
              title: "title",
            ),
          ),
        ),
        List.generate(
          10,
          (index) => {
            "albumId": "albumId",
            "artist": "artist",
            "filePath": "/file/path",
            "length": index,
            "liked": 1,
            "numListens": index,
            "thumbnail": "thumbnail.png",
            "title": "title",
          },
        ),
      );
    });
  });

  group("Album Data", () {
    test("from map", () {
      expect(
        AlbumData.fromMap({
          "artist": "artist",
          "id": "id",
          "imagePath": "/image/path",
          "name": "name",
          "numSongs": 10,
        }),
        AlbumData(
            artist: "artist",
            id: "id",
            imagePath: "/image/path",
            name: "name",
            numSongs: 10),
      );
    });
    test("from map array", () {
      expect(
        AlbumData.fromMapArray(
          List.generate(
            10,
            (index) => {
              "id": "id",
              "artist": "artist",
              "imagePath": "/image/path",
              "numSongs": index,
              "name": "name",
            },
          ),
        ),
        List.generate(
          10,
          (index) => AlbumData(
            id: "id",
            artist: "artist",
            imagePath: "/image/path",
            numSongs: index,
            name: "name",
          ),
        ),
      );
    });
    test("to map", () {
      expect(
        AlbumData.toMap(AlbumData(
          id: "id",
          artist: "artist",
          imagePath: "/image/path",
          numSongs: 10,
          name: "name",
        )),
        {
          "id": "id",
          "artist": "artist",
          "imagePath": "/image/path",
          "numSongs": 10,
          "name": "name",
        },
      );
    });
    test("to map array", () {
      expect(
        AlbumData.toMapArray(
          List.generate(
            10,
            (index) => AlbumData(
              id: "id",
              artist: "artist",
              imagePath: "/image/path",
              numSongs: index,
              name: "name",
            ),
          ),
        ),
        List.generate(
          10,
          (index) => {
            "id": "id",
            "artist": "artist",
            "imagePath": "/image/path",
            "numSongs": index,
            "name": "name",
          },
        ),
      );
    });
  });

  group("Custom Album Data", () {
    test("from map", () {
      expect(
        CustomAlbumData.fromMap({
          "id": "id",
          "name": "name",
          "songs": '"song1","song2"',
        }),
        CustomAlbumData(
          id: "id",
          name: "name",
          songs: ["song1", "song2"],
        ),
      );
    });
    test("from map array", () {
      expect(
        CustomAlbumData.fromMapArray(
          List.generate(
            10,
            (index) => {
              "id": "id",
              "name": "name",
              "songs": '"song\'1","song2"',
            },
          ),
        ),
        List.generate(
          10,
          (index) => CustomAlbumData(
            id: "id",
            name: "name",
            songs: ["song'1", "song2"],
          ),
        ),
      );
    });
    test("to map", () {
      expect(
        CustomAlbumData.toMap(CustomAlbumData(
          id: "id",
          name: "name",
          songs: ["song'1", "song2"],
        )),
        {
          "id": "id",
          "name": "name",
          "songs": '"song\'1","song2"',
        },
      );
    });
    test("to map array", () {
      expect(
        CustomAlbumData.toMapArray(
          List.generate(
            10,
            (index) => CustomAlbumData(
              id: "id",
              name: "name",
              songs: ["song1", "song2"],
            ),
          ),
        ),
        List.generate(
          10,
          (index) => {
            "id": "id",
            "name": "name",
            "songs": '"song1","song2"',
          },
        ),
      );
    });
  });
}
