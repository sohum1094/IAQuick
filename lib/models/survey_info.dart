import 'dart:convert';


class SurveyInfo {
  int? id;
  String siteName = "";
  DateTime date = DateTime.parse("19700101");
  String address = "";
  String occupancyType = "";
  bool carbonDioxideReadings = false;
  bool carbonMonoxideReadings = false;
  bool vocs = false;
  bool pm25 = false;
  bool pm10 = false;
  
    // Default constructor
  SurveyInfo()
      : id = -1, 
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
    this.id, // Allow passing an existing ID
    required this.siteName,
    required this.date,
    required this.address,
    required this.occupancyType,
    this.carbonDioxideReadings = false,
    this.carbonMonoxideReadings = false,
    this.vocs = false,
    this.pm25 = false,
    this.pm10 = false,
  }); // Use existing ID or generate a new one

  Map<String, dynamic> toJson() {
    final Map<String,dynamic> data = {
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
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  SurveyInfo.fromMap(Map<String, dynamic> map)
    : id = map['id'], // Assign an existing ID or generate a new one
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
  int surveyID;
  double temperature;
  double relativeHumidity;
  double? co2; // nullable
  double? co; // nullable
  double? pm25; // nullable
  double? pm10; // nullable
  double? vocs; // nullable

  OutdoorReadings({
    this.surveyID = -1,
    this.temperature = 0.0,
    this.relativeHumidity = 0.0,
    this.co2,
    this.co,
    this.pm25,
    this.pm10,
    this.vocs,
  });

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
      surveyID: map['surveyID']?.toInt() ?? -1,
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
  int? id;
  int surveyID;
  String building;
  int floorNumber;
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
    this.id, // Optional id
    this.surveyID = -1,
    this.building = "default",
    this.floorNumber = 0,
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
  }); // Assign a new UUID if id is not provided

  RoomReading.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? -1, // Use existing id or generate a new one
        surveyID = map['surveyID'] ?? -1,
        building = map['building'] ?? "default",
        floorNumber = map['floorNumber'] ?? 0,
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
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}


