import 'package:uuid/uuid.dart';
import 'dart:io';

class SurveyInfo {
  String id; // id is now a non-nullable String
  String siteName;
  String projectNumber;
  DateTime date;
  String address;
  String occupancyType;
  bool carbonDioxideReadings;
  bool carbonMonoxideReadings;
  bool vocs;
  bool pm25;
  bool pm10;
  bool no2;
  bool so2;
  bool no;

  // Default constructor
  SurveyInfo()
      : id = const Uuid().v4(), // Generate a new UUID
        siteName = "",
        projectNumber = "",
        date = DateTime.parse("19700101"),
        address = "",
        occupancyType = "",
        carbonDioxideReadings = false,
        carbonMonoxideReadings = false,
        vocs = false,
        pm25 = false,
        pm10 = false,
        no2 = false,
        so2 = false,
        no = false;

  // Parameterized constructor
  SurveyInfo.parameterized({
    String? id, // Accept an existing ID as nullable
    required this.siteName,
    this.projectNumber = '',
    required this.date,
    required this.address,
    required this.occupancyType,
    this.carbonDioxideReadings = false,
    this.carbonMonoxideReadings = false,
    this.vocs = false,
    this.pm25 = false,
    this.pm10 = false,
    this.no2 = false,
    this.so2 = false,
    this.no = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    final Map<String,dynamic> data = {
      'id' : id,
      'siteName': siteName,
      'projectNumber': projectNumber,
      'date': date.toIso8601String(),
      'address': address,
      'occupancyType': occupancyType,
      'carbonDioxideReadings': carbonDioxideReadings ? 1 : 0,
      'carbonMonoxideReadings': carbonMonoxideReadings ? 1 : 0,
      'vocs': vocs ? 1 : 0,
      'pm25': pm25 ? 1 : 0,
      'pm10': pm10 ? 1 : 0,
      'no2': no2 ? 1 : 0,
      'so2': so2 ? 1 : 0,
      'no': no ? 1 : 0,
    };
    return data;
  }

  SurveyInfo.fromMap(Map<String, dynamic> map)
    : id = map['id'] ?? const Uuid().v4(), // Assign an existing ID or generate a new one
      siteName = map['siteName'] ?? "",
      projectNumber = map['projectNumber'] ?? "",
      date = DateTime.tryParse(map['date']) ?? DateTime.parse("1970-01-01"),
      address = map['address'] ?? "",
      occupancyType = map['occupancyType'] ?? "",
      carbonDioxideReadings = map['carbonDioxideReadings'] == 1,
      carbonMonoxideReadings = map['carbonMonoxideReadings'] == 1,
      vocs = map['vocs'] == 1,
      pm25 = map['pm25'] == 1,
      pm10 = map['pm10'] == 1,
      no2 = map['no2'] == 1,
      so2 = map['so2'] == 1,
      no = map['no'] == 1;
}

class OutdoorReadings {
  String surveyID;
  double temperature;
  double relativeHumidity;
  double? co2; // nullable
  double? co; // nullable
  double? pm25; // nullable
  double? pm10; // nullable
  double? vocs; // nullable
  double? no2; // nullable
  double? so2; // nullable
  double? no; // nullable
  DateTime timestamp;

  OutdoorReadings({
    String? surveyID,
    this.temperature = 0.0,
    this.relativeHumidity = 0.0,
    this.co2,
    this.co,
    this.pm25,
    this.pm10,
    this.vocs,
    DateTime? timestamp,
  })  : surveyID = surveyID ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'surveyID': surveyID,
      'temperature': temperature,
      'relativeHumidity': relativeHumidity,
      'co2': co2,
      'co': co,
      'pm25': pm25,
      'pm10': pm10,
      'vocs': vocs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OutdoorReadings.fromMap(Map<String, dynamic> map) {
    return OutdoorReadings(
      surveyID: map['surveyID'],
      temperature: map['temperature']?.toDouble() ?? -1.0,
      relativeHumidity: map['relativeHumidity']?.toDouble() ?? -1.0,
      co2: map['co2']?.toDouble(),
      co: map['co']?.toDouble(),
      pm25: map['pm25']?.toDouble(),
      pm10: map['pm10']?.toDouble(),
      vocs: map['vocs']?.toDouble(),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}


class RoomReading {
  int? id;
  String surveyID;
  String building;
  String floorNumber;
  String roomNumber;
  String primaryUse;
  double temperature;
  double relativeHumidity;
  double? co2; // nullable
  double? co; // nullable
  double? pm25; // nullable
  double? pm10; // nullable
  double? vocs; // nullable
  double ? no2; // nullable
  double ? so2; // nullable
  double ? no; // nullable
  String comments;
  bool isOutdoor;
  DateTime timestamp;
  List<File> images;

  RoomReading({
    this.id, // Optional id
    String? surveyID,
    this.building = "default",
    this.floorNumber = "0",
    this.roomNumber = "default",
    this.primaryUse = "default",
    this.temperature = 0,
    this.relativeHumidity = 0,
    this.co2,
    this.co,
    this.pm25,
    this.pm10,
    this.vocs,
    this.no2,
    this.so2,
    this.no,
    this.comments = "No issues were observed.",
    this.isOutdoor = false,
    List<File>? images,
    DateTime? timestamp,
  })  : surveyID = surveyID ?? const Uuid().v4(), // Assign a new UUID if id is not provided
        images = images ?? [],
        timestamp = timestamp ?? DateTime.now();

  RoomReading.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? -1, // Use existing id or generate a new one
        surveyID = map['surveyID'] ?? "default",
        building = map['building'] ?? "default",
        floorNumber = map['floorNumber'] ?? "0",
        roomNumber = map['roomNumber'] ?? "default",
        primaryUse = map['primaryUse'] ?? "default",
        temperature = map['temperature']?.toDouble() ?? 0,
        relativeHumidity = map['relativeHumidity']?.toDouble() ?? 0,
        co2 = map['co2']?.toDouble(),
        co = map['co']?.toDouble(),
        pm25 = map['pm25']?.toDouble(),
        pm10 = map['pm10']?.toDouble(),
        vocs = map['vocs']?.toDouble(),
        no2 = map['no2']?.toDouble(),
        so2 = map['so2']?.toDouble(),
        no = map['no']?.toDouble(),
        comments = map['comments'] ?? "No issues were observed.",
        isOutdoor = map['isOutdoor'] == 1 || map['isOutdoor'] == true,
        timestamp = DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now(),
        images = [];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'surveyID': surveyID,
      'building': building,
      'floorNumber': floorNumber,
      'roomNumber': roomNumber,
      'primaryUse': primaryUse,
      'temperature': temperature,
      'relativeHumidity': relativeHumidity,
      'co2': co2,
      'co': co,
      'pm25': pm25,
      'pm10': pm10,
      'vocs': vocs,
      'no2': no2,
      'so2': so2,
      'no': no,
      'comments': comments,
      'isOutdoor': isOutdoor ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}


