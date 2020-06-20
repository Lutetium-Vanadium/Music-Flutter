import 'package:sqflite/sqflite.dart';

Future<Database> getDB() async {
  var db = await openDatabase(
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
  );

  return db;
}

abstract class Tables {
  static const Songs = "songdata";
  static const Albums = "albumdata";
  static const CustomAlbums = "customalbums";
}
