import 'package:flutter/material.dart';
import 'package:iaqapp/new_survey/new_survey_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'existing_survey_screen.dart';
import 'user_info/user_initial_info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndShowUserInfoDialog();
  }

  Future<void> _checkAndShowUserInfoDialog() async {
    final shouldShowDialog = await getUserInfoDialogStatus();

    if (shouldShowDialog) {
      _showEnterUserInfoDialog(context);
    }
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

  Future<bool> getUserInfoDialogStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('First Name') == null ||
        prefs.getString('First Name') == '');
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
}

// import 'package:flutter/material.dart';
// import 'package:iaqapp/new_survey/new_survey_start.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'existing_survey_screen.dart';
// import 'user_info/user_initial_info.dart';

// void main() {
//   runApp(const HomeScreen());
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Fetch the boolean value from SharedPreferences
    

//     getUserInfoDialogStatus().then((shouldShowDialog) {
//       if (shouldShowDialog) {
//         debugPrint('should show triggered');
//         _showEnterUserInfoDialog(context);
//       }
//     },
//     );

//     return MaterialApp(
//       home: Builder(
//         builder: (context) => Scaffold(
//           appBar: 
//           body: 
//         ),
//       ),
//     );
//   }





// void _showEnterUserInfoDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: true, // Dialog can be dismissed by tapping outside
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Welcome to IAQuick!'),
//         content: const Text('Please enter user information.'),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (BuildContext context) {
//                     return const UserInitialInfo();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<bool> getUserInfoDialogStatus() async {
//       final prefs = await SharedPreferences.getInstance();
//       return (prefs.getString('First Name') == null ||
//           prefs.getString('First Name') == ''); // Default to true if not found
//     }


