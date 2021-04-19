import 'package:sqflite/sqflite.dart';

class MusicLibrary {}

class MusicLibraryProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db
            .execute("create table songs (songid text primary key, songtitle)");
      },
    );
  }
}
