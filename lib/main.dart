import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:iaqapp/new_survey/new_survey_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'existing_survey_screen.dart';
import 'user_info/user_initial_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'survey_service.dart';

final SurveyService surveyService = SurveyService();



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SurveyService.configureFirestoreCache();
  surveyService.startConnectivityListener();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserInfoDialogStatus(),
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
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Retrieve dialog status on initialization
    context
        .read<UserInfoDialogStatus>()
        .getUserInfoDialogStatus()
        .then((_) {
      if (mounted &&
          context.read<UserInfoDialogStatus>().shouldShowDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showEnterUserInfoDialog(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const UserInitialInfo();
              },
            ),
          ),
        ),
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
              "Open Previous Survey",
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
              "Create New Survey",
              textScaleFactor: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showEnterUserInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Welcome to IAQuick!'),
          content: const Text('Please enter user information.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const UserInitialInfo();
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class UserInfoDialogStatus extends ChangeNotifier {
  bool _shouldShowDialog = false;

  bool get shouldShowDialog => _shouldShowDialog;

  Future<void> getUserInfoDialogStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _shouldShowDialog = (prefs.getString('First Name') == null ||
        prefs.getString('First Name') == '');

    notifyListeners();
  }
}


