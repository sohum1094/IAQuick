import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:iaqapp/main.dart';

class RoomReadingsFormScreen extends StatelessWidget {
  const RoomReadingsFormScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            deleteLastLineFromCSV();
          },
        ),
        title: const Text("Room Readings"),
        centerTitle: true,
      ),
      body: const RoomReadingsForm(),
    );
  }
}

class RoomReadingsForm extends StatefulWidget {
  const RoomReadingsForm({super.key});

  @override
  RoomReadingsFormState createState() => RoomReadingsFormState();
}

class RoomReadingsFormState extends State<RoomReadingsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController roomNumberTextController = TextEditingController();
  TextEditingController primaryUseTextController = TextEditingController();
  TextEditingController humiditiyTextController = TextEditingController();
  TextEditingController temperatureTextController = TextEditingController();
  FieldModel showFieldModel = FieldModel();
  DropdownModel dropdownModel = DropdownModel();

  // Add other dropdown controllers and variables here
  TextEditingController dioxTextController = TextEditingController();
  TextEditingController monoxTextController = TextEditingController();
  TextEditingController vocsTextController = TextEditingController();
  TextEditingController pm25TextController = TextEditingController();
  TextEditingController pm10TextController = TextEditingController();

  TextEditingController commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSharedPrefs();
  }

  Future<void> loadSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check SharedPreferences for a condition to show the text entry fields
    bool shouldShowDiox = prefs.getBool('Carbon Dioxide') ?? false;
    bool shouldShowMonox = prefs.getBool('Carbon Monoxide') ?? false;
    bool shouldShowVOCs = prefs.getBool('VOCs') ?? false;
    bool shouldShowPM25 = prefs.getBool('PM2.5') ?? false;
    bool shouldShowPM10 = prefs.getBool('PM10') ?? false;
    showFieldModel = FieldModel(
        carbonDioxideReadings: shouldShowDiox,
        carbonMonoxideReadings: shouldShowMonox,
        vocs: shouldShowVOCs,
        pm25: shouldShowPM25,
        pm10: shouldShowPM10,
        outdoorCarbonDioxide: prefs.getDouble('outdoorCarbonDioxide') ?? 0,
        comment: "");

    setState(() {
      // Set the initial values of your text controllers based on SharedPreferences
      roomNumberTextController.text = '';
      primaryUseTextController.text = '';
      humiditiyTextController.text = '';
      temperatureTextController.text = '';

      // Add similar logic for other form fields
    });
  }

  void _saveForm() async {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      List<String> iaqRoomReadingsRow = [
        dropdownModel.building,
        dropdownModel.floor,
        roomNumberTextController.text,
        primaryUseTextController.text,
        humiditiyTextController.text,
        temperatureTextController.text,
      ];
      if (showFieldModel.carbonDioxideReadings) {
        iaqRoomReadingsRow.add(dioxTextController.text);
      }
      if (showFieldModel.carbonMonoxideReadings) {
        iaqRoomReadingsRow.add(monoxTextController.text);
      }
      if (showFieldModel.vocs) {
        iaqRoomReadingsRow.add(vocsTextController.text);
      }
      if (showFieldModel.pm25) {
        iaqRoomReadingsRow.add(pm25TextController.text);
      }
      if (showFieldModel.pm10) {
        iaqRoomReadingsRow.add(pm10TextController.text);
      }


      List<String> visualRoomReadingsRow = [
        dropdownModel.building,
        dropdownModel.floor,
        roomNumberTextController.text,
        primaryUseTextController.text,
        commentTextController.text,
      ];
      writeIAQ(iaqRoomReadingsRow);

    }
  }

  @override
  Widget build(BuildContext context) {
    bool savedPressed = false; // Initialize the button state

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  // Static text and dropdown fields that are always shown
                  //Room desc title
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width * .4,
                    child: const Center(
                      child: Text(
                        'Room description',
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: buildingDropdownTemplate(context, dropdownModel),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex: 3,
                        child: floorDropdownTemplate(context, dropdownModel),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      //Room number
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: roomNumberTextController,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value == null) {
                              return null;
                            } else if (value.isNotEmpty &&
                                !RegExp(r'[0-9.-a-zA-Z]+').hasMatch(value)) {
                              return "Enter Valid Room Number";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: "Room #",
                          ),
                        ),
                      ),
                    ],
                  ),

                  //Primary Use
                  TextFormField(
                    controller: primaryUseTextController,
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      if (value == null) {
                        return null;
                      } else if (value.isNotEmpty &&
                          !RegExp(r'^[a-zA-Z\s\-\/]+$').hasMatch(value)) {
                        return "Enter Valid Primary Use Value";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Primary Use",
                    ),
                    // primaryUse
                  ),
                  //room readings
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width * .4,
                    child: const Center(
                      child: Text(
                        'Readings',
                      ),
                    ),
                  ),
                  //Relative Humidity
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: humiditiyTextController,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value == null) {
                              return null;
                            } else if (value.isNotEmpty &&
                                !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                              return "Enter Correct Relative Humidity Value";
                            } else {
                              return null;
                            }
                          },
                          onEditingComplete: () {
                            bool seen = false;

                            if (!seen &&
                                double.parse(humiditiyTextController.text) >
                                    65) {
                              seen = true;
                              _showConfirmValueDialog(
                                  context, 'relative humidity');
                            }
                          },
                          onChanged: (value) {
                            bool seen = false;

                            if (!seen &&
                                (double.parse(value) > 65)) {
                              seen = true;
                              _showConfirmValueDialog(context, 'temperature');
                            }
                          },
                          decoration: const InputDecoration(
                              suffixText: '%',
                              labelText: "Relative Humidity (%)"),
                          // humidity
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex: 3,
                        child: //Temperature
                            TextFormField(
                          controller: temperatureTextController,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value == null) {
                              return null;
                            } else if (value.isNotEmpty &&
                                !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                              return "Enter Correct Temperature Value";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            bool seen = false;

                            if (!seen &&
                                (double.parse(value) > 76 ||
                                    double.parse(value) < 68)) {
                              seen = true;
                              _showConfirmValueDialog(context, 'temperature');
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: "Temperature (F)",
                            suffixText: 'F',
                          ),
                          // temperature
                        ),
                      ),
                    ],
                  ),

                  // Conditional text entry fields
                  if (showFieldModel.carbonDioxideReadings)
                    TextFormField(
                      controller: dioxTextController,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                          return "Enter Correct Carbon Dioxide Value";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        bool seen = false;

                        if (!seen &&
                            double.parse(value) >
                                showFieldModel.outdoorCarbonDioxide + 700) {
                          seen = true;
                          _showConfirmValueDialog(context, 'Carbon Dioxide');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Carbon Dioxide',
                        suffixText: 'PPM',
                      ),
                      // Define your text input properties here
                    ),
                  if (showFieldModel.carbonMonoxideReadings)
                    TextFormField(
                      controller: monoxTextController,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                          return "Enter Correct Carbon Monoxide Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            double.parse(monoxTextController.text) > 10) {
                          seen = true;
                          _showConfirmValueDialog(context, 'Carbon Monoxide');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Carbon Monoxide',
                        suffixText: 'PPM',
                      ),

                      // Define your text input properties here
                    ),
                  if (showFieldModel.vocs)
                    TextFormField(
                      controller: vocsTextController,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                          return "Enter Correct VOCs Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            double.parse(vocsTextController.text) > 3.0) {
                          seen = true;
                          _showConfirmValueDialog(context, 'VOCs');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'VOCs',
                        suffixText: 'mg/m^3',
                      ),
                      // Define your text input properties here
                    ),
                  if (showFieldModel.pm25)
                    TextFormField(
                      controller: pm25TextController,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                          return "Enter Correct PM 2.5 Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            double.parse(pm25TextController.text) > 35) {
                          seen = true;
                          _showConfirmValueDialog(context, 'PM 2.5');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'PM 2.5',
                        suffixText: 'mg/m^3',
                      ),
                      // Define your text input properties here
                    ),
                  if (showFieldModel.pm10)
                    TextFormField(
                      controller: pm10TextController,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                          return "Enter Correct PM10 Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            double.parse(pm10TextController.text) > 150) {
                          seen = true;
                          _showConfirmValueDialog(context, 'PM 10');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'PM 10',
                        suffixText: 'mg/m^3',
                      ),
                      // Define your text input properties here
                    ),
                  TextFormField(
                    controller: commentTextController,
                    decoration: const InputDecoration(
                      labelText: "Enter any comments",
                    ),
                    // Define your text input properties here
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Save button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .33,
                    height: MediaQuery.of(context).size.height * .07,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!savedPressed) {
                          if (_formKey.currentState!.validate() &&
                              !(roomNumberTextController.text == '')) {
                            _saveForm();
                            savedPressed = true;
                          } else {
                            _showErrorDialog(context,
                                'Please enter all room info correctly before saving.');
                          }
                        }
                      },
                      child: const Text(
                        'Save Info',
                        textScaleFactor: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  roomNumberTextController.clear();
                  primaryUseTextController.clear();
                  humiditiyTextController.clear();
                  temperatureTextController.clear();
                  //add dropdowns
                  dioxTextController.clear();
                  monoxTextController.clear();
                  vocsTextController.clear();
                  pm25TextController.clear();
                  pm10TextController.clear();

                  commentTextController.clear();

                  savedPressed = false;
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .33,
                  height: MediaQuery.of(context).size.height * .07,
                  child: const Center(
                    child: Text(
                      "Add Room",
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      !(roomNumberTextController.text == '')) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const HomeScreen();
                        },
                      ),
                    );
                  } else {
                    _showErrorDialog(context,
                        'Please click "Save Info" to save current room info before closing.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .33,
                  height: MediaQuery.of(context).size.height * .07,
                  child: const Center(
                    child: Text(
                      "Finish Survey",
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FieldModel {
  bool carbonDioxideReadings = false;
  bool carbonMonoxideReadings = false;
  bool vocs = false;
  bool pm25 = false;
  bool pm10 = false;
  double outdoorCarbonDioxide = 0;
  String comment = "";

  FieldModel(
      {this.carbonDioxideReadings = false,
      this.carbonMonoxideReadings = false,
      this.vocs = false,
      this.pm25 = false,
      this.pm10 = false,
      this.outdoorCarbonDioxide = 0,
      this.comment = ""});
}

Future<void> deleteLastLineFromCSV() async {
  // Read the existing CSV file
  final prefs = await SharedPreferences.getInstance();
  final csvFilePath = prefs.getString('csvPath')!;
  final inputCSV = File(csvFilePath);
  final inputContent = await inputCSV.readAsString();

  // Parse the CSV data
  const csvConverter = CsvToListConverter();
  List<List<dynamic>> csvData = csvConverter.convert(inputContent);

  // Check if there are any lines to delete
  if (csvData.isNotEmpty) {
    // Remove the last line from the data
    csvData.removeLast();
    // Write the updated data back to the CSV file
    final outputContent = const ListToCsvConverter().convert(csvData);
    await inputCSV.writeAsString(outputContent);
  }
}

Future<void> writeIAQ(List<dynamic> roomReadingsRow) async {
  final prefs = await SharedPreferences.getInstance();
  final iaqCSV = const ListToCsvConverter().convert([roomReadingsRow]);
  final appDocumentsDirectory = await getApplicationDocumentsDirectory();
  // Define the CSV files directory within the app's documents directory
  final iaqDirectory =
      Directory('${appDocumentsDirectory.path}/iaQuick/csv_files/${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('firstName')?.substring(1)}_${prefs.getString('lastName')?.substring(1)}');
  await iaqDirectory.create(recursive: true);
  final iaqFilePath =
      '${appDocumentsDirectory.path}\\iaQuick\\csv_files\\${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('firstName')?.substring(1)}_${prefs.getString('lastName')?.substring(1)}_IAQ.csv';
  final file = File(iaqFilePath).openWrite(mode: FileMode.append);
  file.write('\n');
  file.write(iaqCSV);
}

Future<void> writeVisualAssessment(List<dynamic> roomReadingsRow) async {
  final prefs = await SharedPreferences.getInstance();
  final visualCSV = const ListToCsvConverter().convert([roomReadingsRow]);
  final appDocumentsDirectory = await getApplicationDocumentsDirectory();
  // Define the CSV files directory within the app's documents directory
  final visualDirectory =
      Directory('${appDocumentsDirectory.path}/iaQuick/csv_files/${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('firstName')?.substring(1)}_${prefs.getString('lastName')?.substring(1)}');
  await visualDirectory.create(recursive: true);
  final visualFilePath =
      '${appDocumentsDirectory.path}\\iaQuick\\csv_files\\${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('firstName')?.substring(1)}_${prefs.getString('lastName')?.substring(1)}_Visual_Assessment.csv';
  final file = File(visualFilePath).openWrite(mode: FileMode.append);
  file.write('\n');
  file.write(visualCSV);
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

void _showConfirmValueDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true, // Dialog can be dismissed by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Warning'),
        content: Text(
            'The entry for $message is very high/low please confirm value'),
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

DropdownButtonFormField buildingDropdownTemplate(
    BuildContext context, DropdownModel model) {
  List<String> options = ['Main', 'Annex', 'Other'];

  return DropdownButtonFormField(
    decoration: const InputDecoration(
      labelText: 'Building',
    ),
    validator: (value) {
      if (value.isEmpty) {
        return "Enter Building";
      } else {
        return null;
      }
    },
    items: options.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (value) {
      model.building = value;
    },
    onSaved: (value) {
      model.floor = value;
    },
  );
}

DropdownButtonFormField floorDropdownTemplate(
    BuildContext context, DropdownModel model) {
  List<String> options = [
    'B',
    'G',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'Other'
  ];

  return DropdownButtonFormField(
    decoration: const InputDecoration(
      labelText: 'Floor #',
    ),
    validator: (value) {
      if (value.isEmpty) {
        return "Enter Floor Number";
      } else {
        return null;
      }
    },
    items: options.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (value) {
      model.floor = value;
    },
    onSaved: (value) {
      model.floor = value;
    },
  );
}

class DropdownModel {
  String building = '';
  String floor = '';

  DropdownModel({this.building = '', this.floor = ''});
}
