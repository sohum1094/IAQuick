// Data models for Firestore-based survey storage
import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyHeader {
  final DateTime surveyDate;
  final String occupancyStatus;
  final Map<String, dynamic> extra;

  SurveyHeader({
    required this.surveyDate,
    required this.occupancyStatus,
    this.extra = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'surveyDate': Timestamp.fromDate(surveyDate),
      'occupancyStatus': occupancyStatus,
      ...extra,
    };
  }

  factory SurveyHeader.fromMap(Map<String, dynamic> map) {
    final extra = Map<String, dynamic>.from(map)..remove('surveyDate')..remove('occupancyStatus');
    return SurveyHeader(
      surveyDate: (map['surveyDate'] as Timestamp).toDate(),
      occupancyStatus: map['occupancyStatus'] ?? '',
      extra: extra,
    );
  }
}

class Measurement {
  final String building;
  final int? floorNumber;
  final String roomNumber;
  final String primaryRoomUse;
  final double? temperatureF;
  final double? relativeHumidityPct;
  final int? co2ppm;
  final double? pm25mgm3;

  Measurement({
    required this.building,
    this.floorNumber,
    required this.roomNumber,
    required this.primaryRoomUse,
    this.temperatureF,
    this.relativeHumidityPct,
    this.co2ppm,
    this.pm25mgm3,
  });

  Map<String, dynamic> toMap() {
    return {
      'building': building,
      'floorNumber': floorNumber,
      'roomNumber': roomNumber,
      'primaryRoomUse': primaryRoomUse,
      'temperatureF': temperatureF,
      'relativeHumidityPct': relativeHumidityPct,
      'co2ppm': co2ppm,
      'pm25mgm3': pm25mgm3,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) => Measurement(
        building: map['building'] ?? '',
        floorNumber: map['floorNumber'],
        roomNumber: map['roomNumber'] ?? '',
        primaryRoomUse: map['primaryRoomUse'] ?? '',
        temperatureF: (map['temperatureF'] as num?)?.toDouble(),
        relativeHumidityPct: (map['relativeHumidityPct'] as num?)?.toDouble(),
        co2ppm: map['co2ppm'],
        pm25mgm3: (map['pm25mgm3'] as num?)?.toDouble(),
      );
}

class VisualAssessment {
  final String building;
  final int? floorNumber;
  final String roomNumber;
  final String primaryRoomUse;
  final String notes;

  VisualAssessment({
    required this.building,
    this.floorNumber,
    required this.roomNumber,
    required this.primaryRoomUse,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'building': building,
      'floorNumber': floorNumber,
      'roomNumber': roomNumber,
      'primaryRoomUse': primaryRoomUse,
      'notes': notes,
    };
  }

  factory VisualAssessment.fromMap(Map<String, dynamic> map) => VisualAssessment(
        building: map['building'] ?? '',
        floorNumber: map['floorNumber'],
        roomNumber: map['roomNumber'] ?? '',
        primaryRoomUse: map['primaryRoomUse'] ?? '',
        notes: map['notes'] ?? '',
      );
}

class PhotoMetadata {
  final String roomNumber;
  final String downloadUrl;
  final String fileName;
  final DateTime? timestamp;

  PhotoMetadata({
    required this.roomNumber,
    required this.downloadUrl,
    required this.fileName,
    this.timestamp,
  });

  factory PhotoMetadata.fromMap(Map<String, dynamic> map) => PhotoMetadata(
        roomNumber: map['roomNumber'] ?? '',
        downloadUrl: map['downloadUrl'] ?? '',
        fileName: map['fileName'] ?? '',
        timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      );
}

class SurveyReport {
  final SurveyHeader header;
  final List<Measurement> measurements;
  final List<VisualAssessment> visuals;
  final List<PhotoMetadata> photos;

  SurveyReport({
    required this.header,
    required this.measurements,
    required this.visuals,
    required this.photos,
  });
}

