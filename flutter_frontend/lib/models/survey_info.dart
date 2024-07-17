import 'package:uuid/uuid.dart';

class SurveyInfo {
  String ID; // id is now a non-nullable String
  String siteName;
  DateTime date;
  String address;
  String occupancyType;
  bool carbonDioxideReadings;
  bool carbonMonoxideReadings;
  bool vocs;
  bool pm25;
  bool pm10;

  // Default constructor
  SurveyInfo()
      : ID = const Uuid().v4(), // Generate a new UUID
        siteName = "",
        date = DateTime.parse("19700101"),
        address = "",
        occupancyType = "",
        carbonDioxideReadings = false,
        carbonMonoxideReadings = false,
        vocs = false,
        pm25 = false,
        pm10 = false;

  // Parameterized constructor
  SurveyInfo.parameterized({
    String? ID, // Accept an existing ID as nullable
    required this.siteName,
    required this.date,
    required this.address,
    required this.occupancyType,
    this.carbonDioxideReadings = false,
    this.carbonMonoxideReadings = false,
    this.vocs = false,
    this.pm25 = false,
    this.pm10 = false,
  }) : ID = ID ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    final Map<String,dynamic> data = {
      'ID' : ID,
      'siteName': siteName,
      'date': date.toIso8601String(),
      'address': address,
      'occupancyType': occupancyType,
      'carbonDioxideReadings': carbonDioxideReadings ? 1 : 0,
      'carbonMonoxideReadings': carbonMonoxideReadings ? 1 : 0,
      'vocs': vocs ? 1 : 0,
      'pm25': pm25 ? 1 : 0,
      'pm10': pm10 ? 1 : 0,
    };
    return data;
  }

  SurveyInfo.fromMap(Map<String, dynamic> map)
    : ID = map['ID'], // Assign an existing ID or generate a new one
      siteName = map['siteName'] ?? "",
      date = DateTime.tryParse(map['date']) ?? DateTime.parse("1970-01-01"),
      address = map['address'] ?? "",
      occupancyType = map['occupancyType'] ?? "",
      carbonDioxideReadings = map['carbonDioxideReadings'] == 1,
      carbonMonoxideReadings = map['carbonMonoxideReadings'] == 1,
      vocs = map['vocs'] == 1,
      pm25 = map['pm25'] == 1,
      pm10 = map['pm10'] == 1;
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

  OutdoorReadings({
    String? surveyID,
    this.temperature = 0.0,
    this.relativeHumidity = 0.0,
    this.co2,
    this.co,
    this.pm25,
    this.pm10,
    this.vocs,
  }): surveyID = surveyID ?? const Uuid().v4();

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
    );
  }
}


class RoomReading {
  int? ID;
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
  String comments;

  RoomReading({
    this.ID, // Optional id
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
    this.comments = "No issues were observed.",
  }): surveyID = surveyID ?? const Uuid().v4(); // Assign a new UUID if id is not provided

  RoomReading.fromMap(Map<String, dynamic> map)
      : ID = map['ID'] ?? -1, // Use existing id or generate a new one
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
        comments = map['comments'] ?? "No issues were observed.";

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
      'comments': comments,
    };
    if (ID != null) {
      data['ID'] = ID;
    }

    return data;
  }
}


