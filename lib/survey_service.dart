import 'dart:io';
import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class SurveyService {
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  /// Configure Firestore persistence with ~15MB cache size.
  static Future<void> configureFirestoreCache() async {
    await FirebaseFirestore.instance.enablePersistence();
  }

  /// Start listening for connectivity changes.
  void startConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
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
        final match = RegExp(r'room_(.+)\.jpg').firstMatch(fileName);
        final roomNumber = match != null ? match.group(1) ?? '' : '';
        final storagePath = 'surveyImages/$surveyId/$fileName';
        try {
          final snapshot = await FirebaseStorage.instance.ref(storagePath).putFile(file);
          final downloadUrl = await snapshot.ref.getDownloadURL();
          await surveyRef.collection('photos').add({
            'roomNumber': roomNumber,
            'downloadUrl': downloadUrl,
            'fileName': fileName,
            'timestamp': FieldValue.serverTimestamp(),
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
}

