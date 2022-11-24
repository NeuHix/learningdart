import 'package:learningdart/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'package:flutter/cupertino.dart';

class NotesService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> deleteUserFromDatabase({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedData = await db.delete(
      userTable,
      where: 'email= ',
      whereArgs: [email.toLowerCase()],
    );
    /* we're doing formatting we're going to say we're going to say delete
    something from the user table as long as that something's email is equal to something and that something is again
    that email so you're basically saying delete as many objects as possible in the user
     table as long as their email is equal to this
    */

    if (deletedData != 1) throw UserDataNotDeleted();
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) throw UserAlreadyExists();

    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserNotFoundInDB();
    } // making sure that he owner exists with the corect id

    var text = "";
    final noteId = await db.insert(noteTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1});
    // putting note in the database

    final note = DatabaseNote(
      id: noteId,
      user_id: owner.id,
      text: text,
      is_synced_w_cloud: true,
    );
    return note; // returned note!! yeah!!!
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final findinDb = await db.query(
      userTable,
      limit: 1,
      where: email,
      whereArgs: [email.toLowerCase()],
    );

    if (findinDb.isEmpty) {
      throw UserNotFoundInDB();
    } else {
      return DatabaseUser.fromRow(findinDb.first);
    }
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final deletingNote = await db.delete(
      noteTable,
      where: "id =?",
      whereArgs: [id],
    );

    if (deletingNote == 0) throw FailedToDeleteNote();
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable, where: "id=?", whereArgs: [id]);

    if (notes.isEmpty) {
      throw ThisNoteIsEmpty();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final allNotes = await db.query(noteTable);
    return allNotes.map((notesRow) => DatabaseNote.fromRow(notesRow));
  }

  Future<void> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();
    final updating = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updating == 0) {
      throw NoteNotUpdatedException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  } // i don't think i'll ever use this!

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbname);
      final db = await openDatabase(dbPath);
      _db = db;

      /// Creating User Table
      await db.execute(createUserTable);

      /// Creating Note Table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToFetchDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> uniq_identifier)
      : email = uniq_identifier[emailColumn] as String,
        id = uniq_identifier[idColumn] as int;

  @override
  String toString() => ("Sapien ID: $id , Email: $email");

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int user_id;
  final String text;
  final bool is_synced_w_cloud;

  DatabaseNote({
    required this.id,
    required this.user_id,
    required this.text,
    required this.is_synced_w_cloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> uniq_identifier)
      : id = uniq_identifier[idColumn] as int,
        user_id = uniq_identifier[userIdColumn] as int,
        text = uniq_identifier[textColumn] as String,
        is_synced_w_cloud =
            (uniq_identifier[isSyncedWithCloudColumn] as int) == 1
                ? true
                : false;

  @override
  String toString() =>
      "Note ID: $id \n User: $user_id \n isSyncedWithCloud: $is_synced_w_cloud";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbname = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'userId';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_w_cloud';
const createNoteTable = '''
        CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER,
        "text"	TEXT,
        "is_synced_w_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );
      ''';
const createUserTable = '''
          CREATE TABLE IF NOT EXISTS "user" (
          "id"	INTEGER NOT NULL UNIQUE,
          "email"	TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
          ); 
          ''';
