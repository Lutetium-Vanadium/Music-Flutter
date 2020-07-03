import "dart:async";
import "package:flutter/material.dart";
import "package:sqflite/sqflite.dart";

import "package:Music/models/models.dart";

class DatabaseProvider extends StatelessWidget {
  final Widget child;
  final DatabaseFunctions database;

  String yeet() => "YEEEEE";

  const DatabaseProvider({Key key, this.database, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  static DatabaseFunctions getDB(BuildContext context) {
    assert(context != null);
    final DatabaseProvider result =
        context.findAncestorWidgetOfExactType<DatabaseProvider>();
    if (result != null) return result.database;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          "DatabaseProvider.of() called with a context that does not contain a DatabaseProvider."),
      ErrorDescription(
          "No DatabaseProvider ancestor could be found starting from the context that was passed to DatabaseProvider.of(). "
          "This usually happens when the context provided is from the same StatefulWidget as that "
          "whose build function actually creates the DatabaseProvider widget being sought."),
      context.describeElement("The context used was")
    ]);
  }
}

class DatabaseFunctions {
  Database _db;
  final _completer = Completer<void>();

  Future<void> get isReady => _completer.future;
  Future<Database> get db async {
    await isReady;
    return _db;
  }

  Future<int> get numLiked async {
    await isReady;

    return (await _db.rawQuery(
      "SELECT COUNT(*) AS cnt FROM ${Tables.Songs} WHERE liked;",
    ))[0]["cnt"];
  }

  DatabaseFunctions() {
    openDatabase(
      "song_info.db",
      version: 1,
      onCreate: (db, version) async {
        print(Tables.Songs);
        print(Tables.Albums);
        print(Tables.CustomAlbums);
        await db.execute("""CREATE TABLE ${Tables.Songs} (
          filePath TEXT,
          title TEXT,
          thumbnail TEXT,
          artist TEXT,
          length INT,
          numListens INT,
          liked BOOLEAN,
          albumId TEXT
        )""");
        await db.execute("""CREATE TABLE ${Tables.Albums} (
          id TEXT,
          imagePath TEXT,
          name TEXT,
          numSongs INT,
          artist TEXT
        )""");
        await db.execute("""CREATE TABLE ${Tables.CustomAlbums} (
          id TEXT,
          name TEXT,
          songs TEXT
        )""");

        print("Created db");
      },
    ).then((db) {
      _db = db;
      _completer.complete();
    });
  }

  Future<Pair<List<SongData>, List<AlbumData>>> getTopData() async {
    await isReady;

    return Pair(
      SongData.fromMapArray(
        await _db.query(Tables.Songs,
            orderBy: "not liked, numListens DESC", limit: 5),
      ),
      AlbumData.fromMapArray(
        await _db.query(Tables.Albums, orderBy: "numSongs DESC", limit: 5),
      ),
    );
  }

  Future<List<SongData>> getSongs({
    String where,
    List<dynamic> whereArgs,
  }) async {
    await isReady;

    return SongData.fromMapArray(await _db.query(
      Tables.Songs,
      orderBy: "LOWER(title), title",
      where: where,
      whereArgs: whereArgs,
    ));
  }

  Future<List<AlbumData>> getAlbums({
    String where,
    List<dynamic> whereArgs,
  }) async {
    await isReady;

    return AlbumData.fromMapArray(await _db.query(
      Tables.Albums,
      orderBy: "LOWER(name), name",
      where: where,
      whereArgs: whereArgs,
    ));
  }

  Future<List<CustomAlbumData>> getCustomAlbums({
    String where,
    List<dynamic> whereArgs,
  }) async {
    await isReady;

    return CustomAlbumData.fromMapArray(await _db.query(
      Tables.CustomAlbums,
      orderBy: "LOWER(name), name",
      where: where,
      whereArgs: whereArgs,
    ));
  }

  Future<int> getNumSongs(String albumId) async {
    await isReady;

    return (await _db.rawQuery(
      "SELECT COUNT(*) AS cnt FROM ${Tables.Songs} WHERE albumId LIKE ?;",
      [albumId],
    ))[0]["cnt"];
  }

  Future<List<ArtistData>> getArtists() async {
    await isReady;

    var preSongs = PreArtist.fromMapArray(await _db.rawQuery(
        "SELECT artist as name, COUNT(*) as numSongs FROM songdata GROUP BY artist;"));

    List<ArtistData> artists = [];

    for (var preSong in preSongs) {
      var images = await _db.query(
        Tables.Albums,
        where: "artist LIKE ?",
        whereArgs: [preSong.name],
        columns: ["imagePath"],
        orderBy: "numSongs DESC",
        limit: 4,
      );

      artists.add(ArtistData.fromMapAndPreArtist(images, preSong));
    }

    return artists;
  }

  Future<void> insert(String table, Map<String, dynamic> values) async {
    await isReady;
    _db.insert(table, values);
  }

  Future<void> insertSong(SongData song) async {
    return insert(Tables.Songs, song.toMap());
  }

  Future<void> insertAlbum(AlbumData album) async {
    return insert(Tables.Albums, album.toMap());
  }

  Future<void> insertCustomAlbum(CustomAlbumData customAlbum) async {
    return insert(Tables.CustomAlbums, customAlbum.toMap());
  }

  Future<int> delete(
    String table, {
    String where,
    List<dynamic> whereArgs,
  }) async {
    await isReady;

    return _db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteSong(String title) async {
    await isReady;

    return _db.delete(
      Tables.Songs,
      where: "title LIKE ?",
      whereArgs: [title],
    );
  }

  Future<int> deleteEmptyAlbums() async {
    await isReady;

    return _db.delete(Tables.Albums, where: "numSongs < 1");
  }

  Future<int> deleteCustomAlbum(String id) async {
    await isReady;

    return _db.delete(
      Tables.CustomAlbums,
      where: "id LIKE ?",
      whereArgs: [id],
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String where,
    List<dynamic> whereArgs,
  }) async {
    await isReady;

    return _db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> incrementNumListens(SongData song) async {
    await isReady;

    return _db.rawUpdate(
      "UPDATE ${Tables.Songs} SET numListens = numListens + 1 WHERE title LIKE ?",
      [song.title],
    );
  }

  Future<String> nextCustomAlbumId() async {
    await isReady;

    var ids = await _db.query(
      Tables.CustomAlbums,
      orderBy: "id DESC",
    );

    int number = 0;
    if (ids.length > 0) {
      number = int.parse(ids.first["id"].substring(4)) + 1;
    }
    return "cst.$number";
  }
}

abstract class Tables {
  static const Songs = "songdata";
  static const Albums = "albumdata";
  static const CustomAlbums = "customalbums";
}
