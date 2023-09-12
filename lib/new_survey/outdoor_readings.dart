import 'package:easy_form_kit/easy_form_kit.dart';
import 'package:flutter/material.dart';
import 'package:iaqapp/new_survey/new_survey_start.dart';
import 'package:iaqapp/new_survey/room_readings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; // Import the path package


final GlobalKey<EasyDataFormState> formKey = GlobalKey<EasyDataFormState>();

class OutdoorReadings extends StatelessWidget {
  const OutdoorReadings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
              '${SurveyInitialInfoFormState.model.siteName} Outdoor Readings'),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .9,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: outdoorReadingsInfoForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget outdoorReadingsInfoForm(BuildContext context) {
  List<dynamic> headerRow = [
    'Building',
    'Floor #',
    'Room #',
    'Primary Room Use',
    'Temperature (F)',
    'Relative Humidity (%)'
  ];
  List<dynamic> outdoorReadingsRow = ['Outdoor', 'N/A', 'N/A', 'Outdoor Air'];

  return FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final prefs = snapshot.data!;
        (prefs.getBool('Carbon Dioxide') ?? false)
            ? headerRow.add('Carbon Dioxide (ppm)')
            : null;
        (prefs.getBool('Carbon Monoxide') ?? false)
            ? headerRow.add('Carbon Monoxide (ppm)')
            : null;
        (prefs.getBool('VOCs') ?? false) ? headerRow.add('VOCs (mg/m3)') : null;
        (prefs.getBool('PM2.5') ?? false)
            ? headerRow.add('PM2.5 (mg/m3)')
            : null;
        (prefs.getBool('PM10') ?? false) ? headerRow.add('PM10 (mg/m3)') : null;

        return EasyDataForm(
          key: formKey,
          onSaved: (values, fieldValues, form) {
            if (form.validate()) {
              outdoorReadingsRow.add(fieldValues['Relative Humidity (%)Field']);
              outdoorReadingsRow.add(fieldValues['Temperature (F)Field']);
              if (prefs.getBool('Carbon Dioxide') ?? false) {
                outdoorReadingsRow.add(fieldValues['Carbon DioxideField']);
                prefs.setDouble('outdoorCarbonDioxide',
                    double.parse(fieldValues['Carbon DioxideField']));
              }
              (prefs.getBool('Carbon Monoxide') ?? false)
                  ? outdoorReadingsRow.add(fieldValues['Carbon MonoxideField'])
                  : null;
              (prefs.getBool('VOCs') ?? false)
                  ? outdoorReadingsRow.add(fieldValues['VOCsField'])
                  : null;
              (prefs.getBool('PM2.5') ?? false)
                  ? outdoorReadingsRow.add(fieldValues['PM2.5Field'])
                  : null;
              (prefs.getBool('PM10') ?? false)
                  ? outdoorReadingsRow.add(fieldValues['PM10Field'])
                  : null;

              writeIAQ(headerRow, outdoorReadingsRow);
              writeVisualAssessment();
              writeMetadata();
            }
          },
          child: Column(
            children: <Widget>[
              outdoorReadingsTextFormFieldTemplate(
                  context, 'Relative Humidity (%)', 1),
              outdoorReadingsTextFormFieldTemplate(
                  context, 'Temperature (F)', 1),
              if (prefs.getBool('Carbon Dioxide') ?? false)
                outdoorReadingsTextFormFieldTemplate(
                    context, 'Carbon Dioxide', 4),
              if (prefs.getBool('Carbon Monoxide') ?? false)
                outdoorReadingsTextFormFieldTemplate(
                    context, 'Carbon Monoxide', 4),
              if (prefs.getBool('VOCs') ?? false)
                outdoorReadingsTextFormFieldTemplate(context, 'VOCs', 4),
              if (prefs.getBool('PM2.5') ?? false)
                outdoorReadingsTextFormFieldTemplate(context, 'PM2.5', 4),
              if (prefs.getBool('PM10') ?? false)
                outdoorReadingsTextFormFieldTemplate(context, 'PM10', 4),
              // Save button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const RoomReadingsFormScreen();
                        },
                      ),
                    );
                  } else {
                    _showErrorDialog(context,
                        'Please enter information correctly before saving.');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}

EasyTextFormField outdoorReadingsTextFormFieldTemplate(
    BuildContext context, String readingType, int digits) {
  return EasyTextFormField(
    name: '${readingType}Field',
    decoration: InputDecoration(
      hintText: 'Enter $readingType',
    ),
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null) {
        return null;
      } else if (value.isNotEmpty &&
          !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
        return "Enter Correct $readingType Value";
      } else {
        return null;
      }
    },
    // onSaved: (newValue) async {
    //   if (newValue != null && newValue.isNotEmpty) {
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.setDouble('${readingType}Outdoor',
    //         double.parse(double.parse(newValue).toStringAsFixed(digits)));
    //   }
    // },
  );
}


// ...

Future<void> writeIAQ(List<dynamic> headerRow, List<dynamic> outdoorReadingsRow) async {
  final prefs = await SharedPreferences.getInstance();
  final iaqCSV = const ListToCsvConverter().convert([
    ['${prefs.getString('Site Name')} Indoor Air Quality Measurements'],
    ['${prefs.getString('Date Time')}'],
    ['${prefs.getString('Occupancy')}'],
    headerRow,
  ]);

  final appDocumentsDirectory = await getApplicationDocumentsDirectory();

  // Define the CSV files directory within the app's documents directory
  final iaqDirectory = Directory(path.join(
    appDocumentsDirectory.path,
    'iaQuick',
    'csv_files',
    '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}',
  ));

  await iaqDirectory.create(recursive: true);

  final iaqFilePath = path.join(
    iaqDirectory.path,
    '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}_IAQ.csv',
  );

  prefs.setString('iaqPath', iaqFilePath);
  debugPrint('wrote the path');

  final file = File(iaqFilePath);
  await file.writeAsString(iaqCSV);
}

Future<void> writeVisualAssessment() async {
  final prefs = await SharedPreferences.getInstance();
  List<dynamic> headerRow = [
    'Building',
    'Floor #',
    'Room #',
    'Primary Room Use',
    'Visual Assesment Notes'
  ];
  final visualCSV = const ListToCsvConverter().convert([
    ['${prefs.getString('Site Name')} Visual Assesment'],
    ['${prefs.getString('Date Time')}'],
    ['${prefs.getString('Occupancy')}'],
    headerRow,
  ]);

  final appDocumentsDirectory = await getApplicationDocumentsDirectory();

  // Define the CSV files directory within the app's documents directory
  final visualDirectory = Directory(path.join(
    appDocumentsDirectory.path,
    'iaQuick',
    'csv_files',
    '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}',
  ));

  await visualDirectory.create(recursive: true);

  final visualFilePath = path.join(
    visualDirectory.path,
    '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}_Visual_Assessment.csv',
  );

  prefs.setString('visualPath', visualFilePath);
  debugPrint('wrote the path');

  final file = File(visualFilePath);
  await file.writeAsString(visualCSV);
}

Future<void> writeMetadata() async {
  final prefs = await SharedPreferences.getInstance();

  final appDocumentsDirectory = await getApplicationDocumentsDirectory();

  // Define the CSV files directory within the app's documents directory
  final metaDirectory = Directory(path.join(
    appDocumentsDirectory.path,
    'iaQuick',
    'csv_files',
    'do_not_edit',
  ));
  await metaDirectory.create(recursive: true);

  final schoolInfo = '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}';

  final iaqFilePath = path.join(
    appDocumentsDirectory.path,
    'iaQuick',
    'csv_files',
    schoolInfo,
    '${schoolInfo}_IAQ.csv',
  );

  final visualFilePath = path.join(
    appDocumentsDirectory.path,
    'iaQuick',
    'csv_files',
    schoolInfo,
    '${schoolInfo}_Visual_Assessment.csv',
  );

  final sourceFilePath = path.join(
    appDocumentsDirectory.path,
    'iaQuick',
    'csv_files',
    schoolInfo,
  );

  final metaCSVPath = path.join(
    appDocumentsDirectory.path,
    'iaQuick',
    'csv_files',
    'do_not_edit',
    'survey_meta.csv',
  );

  final csv = const ListToCsvConverter().convert([
    [
      prefs.getString('Site Name'),
      prefs.getString('Date Time'),
      prefs.getString('Address'),
      iaqFilePath,
      visualFilePath,
      sourceFilePath
    ],
  ]);

  final file = File(metaCSVPath);
  if (!await file.exists()) {
    final headers = const ListToCsvConverter().convert([
      [
        "Site Name",
        "Date",
        "Address",
        "IAQ path",
        "Visual Assesment Path",
        "Source Folder Path"
      ],
    ]);
    file.writeAsString(headers);
  }

  final fileSink = file.openWrite(mode: FileMode.append);
  fileSink.writeln(csv);

  await fileSink.close();
}


void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true, // Dialog can be dismissed by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
