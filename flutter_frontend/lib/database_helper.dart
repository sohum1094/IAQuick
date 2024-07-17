import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:iaqapp/models/survey_info.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE survey_info (
      ID TEXT PRIMARY KEY,
      siteName TEXT,
      date TEXT,
      address TEXT,
      occupancyType TEXT,
      carbonDioxideReadings INTEGER,
      carbonMonoxideReadings INTEGER,
      vocs INTEGER,
      pm25 INTEGER,
      pm10 INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE outdoor_readings (
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      surveyID TEXT,
      temperature REAL,
      relativeHumidity REAL,
      co2 REAL,
      co REAL,
      pm25 REAL,
      pm10 REAL,
      vocs REAL,
      FOREIGN KEY (surveyID) REFERENCES survey_info(ID)
    )
  ''');

    await db.execute('''
    CREATE TABLE room_readings (
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      surveyID TEXT,
      building TEXT,
      floorNumber TEXT,
      roomNumber TEXT,
      primaryUse TEXT,
      temperature REAL,
      relativeHumidity REAL,
      co2 REAL,
      co REAL,
      pm25 REAL,
      pm10 REAL,
      vocs REAL,
      comments TEXT,
      FOREIGN KEY (surveyID) REFERENCES survey_info(ID)
    )
  ''');
  }



  // Add methods for CRUD operations
  Future<int> createSurvey(SurveyInfo surveyInfo) async {
    final db = await instance.database;
    final json = surveyInfo.toJson();  // Convert SurveyInfo to a JSON map
    return db.insert('survey_info', json);
  }

  Future<SurveyInfo?> readSurvey(String ID) async {
    final db = await instance.database;
    final maps = await db.query(
      'survey_info',
      columns: ['ID', 'siteName', 'date', 'address', 'occupancyType', 'carbonDioxideReadings', 'carbonMonoxideReadings', 'vocs', 'pm25', 'pm10'],
      where: 'ID = ?',
      whereArgs: [ID],
    );

    if (maps.isNotEmpty) {
      return SurveyInfo.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateSurvey(SurveyInfo surveyInfo) async {
    final db = await instance.database;
    return db.update(
      'survey_info',
      surveyInfo.toJson(),
      where: 'ID = ?',
      whereArgs: [surveyInfo.ID],
    );
  }

  Future<int> deleteSurvey(String ID) async {
    final db = await instance.database;
    return db.delete(
      'survey_info',
      where: 'ID = ?',
      whereArgs: [ID],
    );
  }

  Future<List<SurveyInfo>> readAllSurveys() async {
    final db = await instance.database;
    final result = await db.query('survey_info');
    print("readAllSurveys result = " + result.toString());
    if (result.isNotEmpty) {
      var list = result.map((json) => SurveyInfo.fromMap(json)).toList();
      print("readAllSurvey list: " + list.toString());
      return list;
    } else {
      return [];
    }
  }

  Future<int> createOutdoorReadings(OutdoorReadings outdoorReadings) async {
    final db = await instance.database;
    final json = outdoorReadings.toJson(); // Convert to JSON map
    // Assuming outdoorReadings.toJson() includes 'surveyID'
    return db.insert('outdoor_readings', json);
  }


  Future<OutdoorReadings?> readOutdoorReadings(String surveyID) async {
    final db = await instance.database;
    final maps = await db.query(
      'outdoor_readings',
      columns: [
        'ID',
        'surveyID',
        'temperature',
        'relativeHumidity',
        'co2',
        'co',
        'pm25',
        'pm10',
        'vocs'
        // Add other columns as needed based on your OutdoorReadings class
      ],
      where: 'surveyID = ?',
      whereArgs: [surveyID],
    );

    if (maps.isNotEmpty) {
      return OutdoorReadings.fromMap(maps.first);
    } else {
      return null;
    }
  }


  Future<int> createRoomReading(RoomReading roomReading, String surveyID) async {
    final db = await instance.database;
    final json = roomReading.toJson();  // Convert to JSON map
    json['surveyID'] = surveyID;
    return db.insert('room_readings', json);
  }

  Future<List<RoomReading>> readRoomReadings(String surveyID) async {
    final db = await instance.database;
    print(await getAllRoomReadingsJson());
    final result = await db.query(
      'room_readings',
      where: 'surveyID = ?',
      whereArgs: [surveyID],
    );
    print(result.toString());
    List<RoomReading> readings = (result.isNotEmpty)? result.map((json) => RoomReading.fromMap(json)).toList() : [];
    print("readRoomReadings input: $surveyID \n readRoomReadings output: roomReadings list of size " + readings.length.toString());
    return readings;
  }

  Future<String> getAllRoomReadingsJson() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('room_readings');
    List<RoomReading> readings = maps.map((map) => RoomReading.fromMap(map)).toList();
    String json = jsonEncode(readings.map((reading) => reading.toJson()).toList());
    return json;
  }


  Future<int> updateRoomReading(RoomReading roomReading) async {
    final db = await instance.database;
    return db.update(
      'room_readings',
      roomReading.toJson(),
      where: 'ID = ?',
      whereArgs: [roomReading.ID],
    );
  }

  Future<int> deleteRoomReading(String id) async {
    final db = await instance.database;
    return db.delete(
      'room_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future close() async {
    final db = await instance.database;
    db.close();
  }


  

}
