import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learningdart/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'package:flutter/cupertino.dart';


class NotesService {
  Database? _db;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamControllerBucket =
        StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamControllerBucket.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;
  List<DatabaseNote> _notes = [];

  late final StreamController<List<DatabaseNote>> _notesStreamControllerBucket;
  var userEmail = FirebaseAuth.instance.currentUser?.email;

  /// Keeping the Notes in an easily accessible bucket through & in
  /// which data is instantly readable and
  /// modifiable (which we can then push to the dB later).
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes(userEmail: userEmail);
    _notes = allNotes.toList();
    _notesStreamControllerBucket.add(_notes);
  }

  /// [[PRIVATE]]
  /// NOTE: This function must not be called without opening the database
  /// in [open].
  ///
  /// Setting db to _db which is private, if it fails, an exception is
  /// thrown, if it succeeds, db variable which is now a Database is returned.
  Database _getDatabaseOrThrow() {
    // Database? _db;
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> ensureDBisOpen() async {
    try {
      await openDB();
    } on DatabaseAlreadyOpenException {
      // return true;
    }
  }

  /// Deleting the User's Data from the Database
  Future<void> deleteUserFromDatabase({required String email}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final deletedData = await db.delete(
      userTable,
      where: 'email= ',
      whereArgs: [email.toLowerCase()],
    );
    /* we're doing formatting. we're going to delete
    something from the user table as long as that something's email is equal to something and that something is again
    that email.
    So you're basically saying delete as many objects as possible in the user
    table as long as their email is equal to this.
    */

    if (deletedData != 1) throw UserDataNotDeleted();
  }

  /// Creating the LoggedIn User in the Database
  Future<DatabaseUser> createUser({required String email}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      /// Searching for user's email in the Database
      userTable,

      /// search in the $userTable (the table containing all user's emails)
      limit: 1,

      /// we want at least 1 occurrence of that email
      where: 'email= ?',

      /// output will be "email= {whereArgs Parameter}" => "?" will be replaced by whereArgs Parameter.
      whereArgs: [email.toLowerCase()],

      /// In this case, the user's email in lower case.
      /// we wanna search for [email]
    );
    if (results.isNotEmpty) {
      /// If the results are not empty meaning that the user is already
      /// in the database
      throw UserAlreadyExists();

      /// throw this exception.
    } else {
      /// If it's empty, Create an entry for that email in the emailColumn.
      final userId = await db.insert(
        /// Insert these in the dB
        userTable, // in the User Table
        {
          emailColumn: email.toLowerCase()
        }, // in the email Column, make an entry for this email in lower cases.
      );

      return DatabaseUser(
        id: userId,
        email: email,
      );
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await ensureDBisOpen();
    try {
      final user = await getUser(email: email);
      return user;
    } on UserNotFoundInDB {
      return await createUser(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserNotFoundInDB();
    } // making sure that the owner exists with the correct id

    var text = "";
    final noteId = await db.insert(noteTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1});
    // putting note in the database

    final note = DatabaseNote(
      id: noteId,
      user_id: owner.id,
      text: text,
      isSyncedWcloud: true,
    );
    _notes.add(note);
    _notesStreamControllerBucket.add(_notes);
    return note; // returned note!! yeah!!!
  }

  void dbExecuteNote() async {
    final db = _db;
    await db?.execute(createNoteTableIfNotExists);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();

    final findinDb = await db.query(
      userTable,
      limit: 1,
      where: "email= ?",
      whereArgs: [email.toLowerCase()],
    );

    if (findinDb.isEmpty) {
      throw UserNotFoundInDB();
    } else {
      return DatabaseUser.fromRow(findinDb.first);
    }
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();

    final deletingNote = await db.delete(
      noteTable,
      where: "id =?",
      whereArgs: [id],
    );

    if (deletingNote == 0) {
      throw FailedToDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamControllerBucket.add(_notes);
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable, where: "id=?", whereArgs: [id]);

    if (notes.isEmpty) {
      throw ThisNoteIsEmpty();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamControllerBucket.stream;

  Future<Iterable<DatabaseNote>> getAllNotes({required userEmail}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final allNotes =
        await db.query(noteTable, where: "email= ?", whereArgs: [userEmail]);

    return allNotes.map((notesRow) => DatabaseNote.fromRow(notesRow));
  }

  Future<Iterable<DatabaseNote>> getAllNotesOfUser({required userEmail}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();

    final allNotes =
        await db.query(noteTable, where: "email= ?", whereArgs: [userEmail]);
    return allNotes.map((notesRow) => DatabaseNote.fromRow(notesRow));
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();

    /// making sure note exists
    await getNote(id: note.id);

    /// updating db
    final updating = await db.update(
        noteTable,
        {
          textColumn: text,
          isSyncedWithCloudColumn: 0,
        },
        where: "id =?",
        whereArgs: [note.id]);

    if (updating == 0) {
      throw NoteNotUpdatedException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamControllerBucket.add(_notes);
      return updatedNote;
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final amountOfDeletions = await db.delete(noteTable);
    _notes = [];

    /// emptying the list after deleting all notes
    _notesStreamControllerBucket.add(_notes);

    /// sending updated  information about notes to our StreamController
    return amountOfDeletions;
  }
  /* i don't think i'll ever use this! */

  Future<void> openDB() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbname);
      final db = await openDatabase(dbPath);
      _db = db;

      /// Creating User Table
      await db.execute(createUserTable);
      await _cacheNotes();

      /// Creating Note Table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToFetchDocumentsDirectory();
    }
  }

  Future<void> closeDB() async {
    await ensureDBisOpen();
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

  DatabaseUser.fromRow(Map<String, Object?> uniqueIdentifier)
      : email = uniqueIdentifier[emailColumn] as String,
        id = uniqueIdentifier[idColumn] as int;

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
  final bool isSyncedWcloud;

  DatabaseNote({
    required this.id,
    required this.user_id,
    required this.text,
    required this.isSyncedWcloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> uniqueIdentifier)
      : id = uniqueIdentifier[idColumn] as int,
        user_id = uniqueIdentifier[userIdColumn] as int,
        text = uniqueIdentifier[textColumn] as String,
        isSyncedWcloud = (uniqueIdentifier[isSyncedWithCloudColumn] as int) == 1
            ? true
            : false;

  @override
  String toString() =>
      "Note ID: $id \n User: $user_id \n isSyncedWithCloud: $isSyncedWcloud";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbname = 'notes.db';
const noteTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_w_cloud';
const createNoteTable = '''
        CREATE TABLE "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER,
	"text"	TEXT,
	"is_synced_w_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);

      ''';

const createNoteTableIfNotExists = '''
    CREATE TABLE IF NOT EXISTS "notes" (
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
