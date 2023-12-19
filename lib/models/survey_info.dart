// class SurveyInfo {
//   String siteName;
//   DateTime date;
//   String occupancyType;
  
//   SurveyInfo({required this.siteName, required this.date, required this.occupancyType});
// }

class SurveyInfo {
  String siteName = "";
  DateTime date = DateTime.parse("19700101");
  String address = "";
  String occupancyType = "";
  bool carbonDioxideReadings = false;
  bool carbonMonoxideReadings = false;
  bool vocs = false;
  bool pm25 = false;
  bool pm10 = false;
  
  SurveyInfo();
  SurveyInfo.parameterized({required this.siteName,required this.date, required this.address, required this.occupancyType, this.carbonDioxideReadings = false,this.carbonMonoxideReadings = false,this.vocs = false, this.pm25 = false, this.pm10 = false});
}

class OutdoorReadings {
  Map<String, dynamic> baselineReadings = {};
  
  OutdoorReadings();
  OutdoorReadings.parameterized({required this.baselineReadings});
}

class RoomReading {
  String building = "default";
  int floorNumber = 0;
  String roomNumber = "default";
  String primaryUse = "default";
  double temperature = 0;
  double relativeHumidity = 0;
  Map<String, dynamic> additionalMetrics = {};
  String comments = "No issues were observed.";
  // Constructor and other methods...
  RoomReading({this.building = "default", this.floorNumber = 0, this.roomNumber = "default", this.primaryUse = "default", this.temperature = 0, this.relativeHumidity =0, this.additionalMetrics = const {}, this.comments = "default"});

  RoomReading.fromMap(Map<String, dynamic> map)
      : building = map['building'] ?? "default",
        floorNumber = map['floorNumber'] ?? 0,
        roomNumber = map['roomNumber'] ?? "default",
        primaryUse = map['primaryUse'] ?? "default",
        temperature = map['temperature']?.toDouble() ?? 0,
        relativeHumidity = map['relativeHumidity']?.toDouble() ?? 0,
        additionalMetrics = map['additionalMetrics'] ?? {},
        comments = map['comments'] ?? "No issues were observed.";
}

