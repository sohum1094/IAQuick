import 'package:flutter/material.dart';
import 'package:iaqapp/new_survey/new_survey_start.dart';
import 'alt_existing_survey_screen.dart';
import 'user_info/user_initial_info.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
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
            return ExistingSurveyScreen(key: key,
            );
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
