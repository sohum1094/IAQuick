import 'dart:io';
import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'models/survey_info.dart';

class SurveyService {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Configure Firestore persistence with ~15MB cache size.
  static Future<void> configureFirestoreCache() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 15 * 1024 * 1024,
    );
  }

  /// Start listening for connectivity changes.
  void startConnectivityListener() {
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      if (!result.contains(ConnectivityResult.none)) {
        await uploadPendingImages();
      }
    });
  }

  /// Cancel connectivity subscription.
  void dispose() {
    _connectivitySub?.cancel();
  }

  /// Create a new survey offline with optional room images.
  Future<String> createSurveyOffline({
    required SurveyHeader header,
    required List<Measurement> measurements,
    required List<VisualAssessment> visuals,
    Map<String, File>? roomImages,
  }) async {
    try {
      final surveyRef = FirebaseFirestore.instance.collection('surveys').doc();
      final batch = FirebaseFirestore.instance.batch();

      batch.set(surveyRef, header.toMap());

      for (final m in measurements) {
        final doc = surveyRef.collection('measurements').doc();
        batch.set(doc, m.toMap());
      }

      for (final v in visuals) {
        final doc = surveyRef.collection('visualAssessments').doc();
        batch.set(doc, v.toMap());
      }

      await batch.commit();

      if (roomImages != null && roomImages.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final surveyDir = Directory(p.join(tempDir.path, 'surveyPending', surveyRef.id));
        await surveyDir.create(recursive: true);
        for (final entry in roomImages.entries) {
          final destPath = p.join(surveyDir.path, 'room_${entry.key}.jpg');
          await entry.value.copy(destPath);
        }
        await addPendingSurvey(surveyRef.id);
      }

      return surveyRef.id;
    } catch (e) {
      print('Error creating survey: $e');
      rethrow;
    }
  }

  /// Save an image for a room locally using the new naming scheme.
  Future<String> saveRoomImageOffline({
    required File image,
    required String surveyId,
    required String building,
    required String floor,
    required String roomNumber,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final surveyDir = Directory(p.join(tempDir.path, 'surveyPending', surveyId));
    await surveyDir.create(recursive: true);

    String sanitize(String value) => value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${surveyId}_${sanitize(building)}_${sanitize(floor)}_${sanitize(roomNumber)}_${timestamp}.jpg';
    final destPath = p.join(surveyDir.path, fileName);
    await image.copy(destPath);
    await addPendingSurvey(surveyId);
    return fileName;
  }

  /// Upload pending images from the temporary folder to Firebase Storage.
  Future<void> uploadPendingImages() async {
    final tempDir = await getTemporaryDirectory();
    final pendingRoot = Directory(p.join(tempDir.path, 'surveyPending'));
    if (!await pendingRoot.exists()) return;

    final surveyDirs = pendingRoot.listSync().whereType<Directory>();
    for (final dir in surveyDirs) {
      final surveyId = p.basename(dir.path);
      final files = dir.listSync().whereType<File>();
      final surveyRef = FirebaseFirestore.instance.collection('surveys').doc(surveyId);

      for (final file in files) {
        final fileName = p.basename(file.path);
        final parts = fileName.split('_');
        String roomNumber = '';
        DateTime? timestamp;
        if (parts.length >= 5) {
          roomNumber = parts[3];
          final tsStr = parts[4].split('.').first;
          final tsInt = int.tryParse(tsStr);
          if (tsInt != null) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(tsInt);
          }
        }
        final storagePath = 'surveyImages/$surveyId/$fileName';
        try {
          final snapshot = await FirebaseStorage.instance.ref(storagePath).putFile(file);
          final downloadUrl = await snapshot.ref.getDownloadURL();
          await surveyRef.collection('photos').add({
            'roomNumber': roomNumber,
            'downloadUrl': downloadUrl,
            'fileName': fileName,
            'timestamp': timestamp,
          });
          await file.delete();
        } catch (e) {
          print('Error uploading $fileName: $e');
        }
      }

      if ((await dir.list().toList()).isEmpty) {
        await dir.delete(recursive: true);
      }

      await removePendingSurvey(surveyId);
    }
  }

  /// SharedPreferences helpers for pending survey IDs
  Future<void> addPendingSurvey(String surveyId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('pendingSurveys') ?? <String>[];
    if (!list.contains(surveyId)) {
      list.add(surveyId);
      await prefs.setStringList('pendingSurveys', list);
    }
  }

  Future<void> removePendingSurvey(String surveyId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('pendingSurveys') ?? <String>[];
    list.remove(surveyId);
    await prefs.setStringList('pendingSurveys', list);
  }

  Future<List<String>> getPendingSurveys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('pendingSurveys') ?? <String>[];
  }

  /// Clear offline Firestore cache and temporary images.
  Future<void> clearOfflineData() async {
    try {
      await FirebaseFirestore.instance.clearPersistence();
    } catch (_) {
      // ignore
    }
    final tempDir = await getTemporaryDirectory();
    final pendingRoot = Directory(p.join(tempDir.path, 'surveyPending'));
    if (await pendingRoot.exists()) {
      await pendingRoot.delete(recursive: true);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pendingSurveys');
  }

  /// Fetch survey report from Firestore.
  Future<SurveyReport> fetchSurveyReport(String surveyId) async {
    final surveyRef = FirebaseFirestore.instance.collection('surveys').doc(surveyId);
    final doc = await surveyRef.get();
    final header = SurveyHeader.fromMap(doc.data()!);

    final measurementsSnap = await surveyRef.collection('measurements').orderBy('building').get();
    final visualsSnap = await surveyRef.collection('visualAssessments').orderBy('building').get();
    final photosSnap = await surveyRef.collection('photos').get();

    final measurements = measurementsSnap.docs.map((d) => Measurement.fromMap(d.data())).toList();
    final visuals = visualsSnap.docs.map((d) => VisualAssessment.fromMap(d.data())).toList();
    final photos = photosSnap.docs.map((d) => PhotoMetadata.fromMap(d.data())).toList();

    return SurveyReport(
      header: header,
      measurements: measurements,
      visuals: visuals,
      photos: photos,
    );
  }

  /// Save a survey composed of [SurveyInfo], [OutdoorReadings] and [RoomReading]
  /// objects to Firestore. Collections are created for outdoor and room
  /// readings so that the app can operate offline using Firestore's built in
  /// persistence.
  Future<void> saveSurveyToFirestore({
    required SurveyInfo info,
    required OutdoorReadings outdoor,
    required List<RoomReading> rooms,
  }) async {
    final surveyRef =
        FirebaseFirestore.instance.collection('surveys').doc(info.id);

    await surveyRef.set(info.toJson());
    await surveyRef
        .collection('outdoor_readings')
        .doc('data')
        .set(outdoor.toJson());

    for (final room in rooms) {
      await surveyRef.collection('room_readings').add(room.toJson());
    }
  }

  /// Fetch all survey headers stored in Firestore ordered by date.
  Future<List<SurveyInfo>> fetchAllSurveys() async {
    final snap = await FirebaseFirestore.instance
        .collection('surveys')
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => SurveyInfo.fromMap(d.data())).toList();
  }

  /// Retrieve room readings for a given [surveyId] from Firestore.
  Future<List<RoomReading>> fetchRoomReadings(String surveyId) async {
    final snap = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(surveyId)
        .collection('room_readings')
        .get();
    return snap.docs.map((d) => RoomReading.fromMap(d.data())).toList();
  }

  /// Retrieve outdoor readings for a survey from Firestore.
  Future<OutdoorReadings?> fetchOutdoorReadings(String surveyId) async {
    final doc = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(surveyId)
        .collection('outdoor_readings')
        .doc('data')
        .get();
    if (!doc.exists) return null;
    return OutdoorReadings.fromMap(doc.data()!);
  }

  /// Delete a survey and its subcollections from Firestore.
  Future<void> deleteSurvey(String surveyId) async {
    final surveyRef =
        FirebaseFirestore.instance.collection('surveys').doc(surveyId);

    final roomSnap = await surveyRef.collection('room_readings').get();
    for (final doc in roomSnap.docs) {
      await doc.reference.delete();
    }

    final outdoorSnap =
        await surveyRef.collection('outdoor_readings').get();
    for (final doc in outdoorSnap.docs) {
      await doc.reference.delete();
    }

    final photosSnap = await surveyRef.collection('photos').get();
    for (final doc in photosSnap.docs) {
      await doc.reference.delete();
    }

    await surveyRef.delete();
  }
}

