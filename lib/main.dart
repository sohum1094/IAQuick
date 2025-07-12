import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth/sign_in_screen.dart';
import 'auth_service.dart';
import 'existing_survey_screen.dart';
import 'new_survey/new_survey_start.dart';
import 'firebase_options.dart';
import 'survey_service.dart';
import 'dart:io' show Platform;

final SurveyService surveyService = SurveyService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  // print("🔥 Firebase.apps.length before init: ${Firebase.apps.length}");
  // for (var app in Firebase.apps) {
  //   print("🔥 Found Firebase app: ${app.name}, ${app.options.projectId}");
  // }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('✅ Firebase initialised by Dart.');
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app' && kDebugMode) {
      print('⚠️ duplicate-app caught – native init already finished.');
    } else {
      rethrow; // Any other error is real and should break.
    }
  }

  await FirebaseAppCheck.instance.activate(
    appleProvider: kDebugMode
        ? AppleProvider.debug               // dev & CI
        : AppleProvider.appAttestWithDeviceCheckFallback, // release
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );

  await SurveyService.configureFirestoreCache();
  await surveyService.startConnectivityListener();
  
  // final token = await FirebaseAppCheck.instance.getToken(true);
  // print('App Check debug token: $token');

  runApp(
    Provider<AuthService>(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    surveyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: authService.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return const SignInScreen();
            } else {
              return const HomeScreen();
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.asset('assets/IAQuick_icon.png'),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();                 // provider + Firebase sign-out
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const SignInScreen();
                  }
                ),
              );
            },
          ),
        ],
        // title: const Text('IAQuick', textScaleFactor: 1.1),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0,32,16,0),
            child: Image.asset(
              'assets/IAQuick_full_logo.png',
              height: 200,
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    createNewSurveyButton(context),
                    const SizedBox(height: 20),
                    openExistingSurveyButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
        
      ),
      backgroundColor: Colors.white,
    );
  }

  ElevatedButton openExistingSurveyButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        elevation: 4.0,
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const ExistingSurveyScreen();
          },
        ),
      ),
      child: Center(
        child: SizedBox(
          height: 75,
          width: MediaQuery.of(context).size.width * .7,
          child: const Center(
            child: Text(
              'Open Previous Survey',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton createNewSurveyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const NewSurveyStart();
          },
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        elevation: 4.0,
      ),
      child: Center(
        child: SizedBox(
          height: 75,
          width: MediaQuery.of(context).size.width * .7,
          child: const Center(
            child: Text(
              'Create New Survey',
            ),
          ),
        ),
      ),
    );
  }
}
