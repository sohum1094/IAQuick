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

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE survey_info (
      ID TEXT PRIMARY KEY,
      siteName TEXT,
      projectNumber TEXT,
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
      isOutdoor INTEGER,
      timestamp TEXT,
      FOREIGN KEY (surveyID) REFERENCES survey_info(ID)
    )
  ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE room_readings ADD COLUMN isOutdoor INTEGER DEFAULT 0");
      await db.execute(
          "ALTER TABLE room_readings ADD COLUMN timestamp TEXT");
    }
    if (oldVersion < 3) {
      await db.execute(
          "ALTER TABLE survey_info ADD COLUMN projectNumber TEXT");
    }
  }



  // Add methods for CRUD operations
  Future<int> createSurvey(SurveyInfo surveyInfo) async {
    final db = await instance.database;
    final json = surveyInfo.toJson();  // Convert SurveyInfo to a JSON map
    return db.insert('survey_info', json);
  }

  Future<SurveyInfo?> readSurvey(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'survey_info',
      columns: ['id', 'siteName', 'projectNumber', 'date', 'address', 'occupancyType', 'carbonDioxideReadings', 'carbonMonoxideReadings', 'vocs', 'pm25', 'pm10'],
      where: 'id = ?',
      whereArgs: [id],
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
      where: 'id = ?',
      whereArgs: [surveyInfo.id],
    );
  }

  Future<int> deleteSurvey(String id) async {
    final db = await instance.database;
    return db.delete(
      'survey_info',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SurveyInfo>> readAllSurveys() async {
    final db = await instance.database;
    final result = await db.query('survey_info');

    if (result.isNotEmpty) {
      return result.map((json) => SurveyInfo.fromMap(json)).toList();
    } else {
      return [];
    }
  }

  Future<int> createRoomReading(RoomReading roomReading) async {
    final db = await instance.database;
    return db.insert('room_readings', roomReading.toJson());
  }

  Future<List<RoomReading>> readRoomReadings(String surveyID) async {
    final db = await instance.database;
    final result = await db.query(
      'room_readings',
      where: 'surveyID = ?',
      whereArgs: [surveyID],
      orderBy: 'timestamp ASC',
    );

    return result.isNotEmpty
        ? result.map((json) => RoomReading.fromMap(json)).toList()
        : [];
  }

  Future<int> updateRoomReading(RoomReading roomReading) async {
    final db = await instance.database;
    return db.update(
      'room_readings',
      roomReading.toJson(),
      where: 'id = ?',
      whereArgs: [roomReading.id],
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
