import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:fluttersql/models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); // named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {

    if ( _databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); // This is executed on;y once singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and ios to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes_db';

    // open/create database at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
        '$colDescription TEXT, $colPriority INT, $colDate TEXT)');
  }

  // fetch operation to get all notes form database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

  // Using raw sql query  var result =  await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC'); // helper function
    return result;
  }

  // insert operation to insert note object into database
  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // update operation to update note object into database
  Future<int> updateNote(Note note) async{
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // delete operation to delete note object from database
  Future<int> deleteNote(int id) async{
    Database db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId= $id');
    return result;
  }

  // get number of Note objects from database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [List<Map>] and convert it to 'Note List' [List<Note>]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count = noteMapList.length;         // Count the number of map entries in db table

    List<Note> noteList = List<Note>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

}