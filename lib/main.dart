import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'auth/sign_in_screen.dart';
import 'auth_service.dart';
import 'existing_survey_screen.dart';
import 'new_survey/new_survey_start.dart';
import 'firebase_options.dart';
import 'survey_service.dart';

final SurveyService surveyService = SurveyService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SurveyService.configureFirestoreCache();
  await surveyService.startConnectivityListener();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest, // Or .deviceCheck
    webProvider: ReCaptchaV3Provider('YOUR_SITE_KEY'), // optional for web
  );

  runApp(
    Provider<AuthService>(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
        title: const Text('IAQuick', textScaleFactor: 1.1),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .95,
          height: MediaQuery.of(context).size.height * .5,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: createNewSurveyButton(context),
              ),
              const Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 3,
                child: openExistingSurveyButton(context),
              ),
            ],
          ),
        ),
      ),
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
          height: MediaQuery.of(context).size.height * .12,
          width: MediaQuery.of(context).size.width * .7,
          child: const Center(
            child: Text(
              'Open Previous Survey',
              textScaleFactor: 1.5,
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
          height: MediaQuery.of(context).size.height * .12,
          width: MediaQuery.of(context).size.width * .7,
          child: const Center(
            child: Text(
              'Create New Survey',
              textScaleFactor: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
