/// This code snippet represents a Flutter form for entering room readings in an indoor air quality (IAQ) survey. 
/// It includes text input fields for room number, primary use, humidity, temperature, and various air quality parameters. 
/// The form also allows the user to select an image and save the form data to a CSV file.
/// 
/// Example Usage:
/// 
/// // Create an instance of the RoomReadingsFormScreen widget
/// final formScreen = RoomReadingsFormScreen();
/// 
/// // Build the form screen widget
/// final formScreenWidget = formScreen.build(context);
/// 
/// // Display the form screen widget
/// return Scaffold(
///   body: formScreenWidget,
/// );
/// 
/// Inputs:
/// - Various text input fields for room number, primary use, humidity, temperature, and air quality parameters.
/// - Image file selected by the user.
/// 
/// Flow:
/// 1. The user enters the room readings and selects an image.
/// 2. The form is validated to ensure that all required fields are filled correctly.
/// 3. If the form is valid, the data is saved to a CSV file.
/// 4. The image is saved locally.
/// 
/// Outputs:
/// - The form data is saved to a CSV file.
/// - The image is saved locally.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:iaqapp/main.dart';
import 'package:path/path.dart' as path;


int roomCount = 0;
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

FocusNode temperatureFocusNode = FocusNode();

File? _imageFile;

bool savedPressed = false; // Initialize the button state


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
            if (roomCount <= 0) {
              Navigator.pop(context);
              debugPrint('room count = $roomCount');
            } else {
              roomCount--;
              debugPrint('room count decrement to = $roomCount');
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

              _imageFile = null;

              savedPressed = false;
            }
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
  final TextEditingController roomNumberTextController = TextEditingController();
  final TextEditingController primaryUseTextController = TextEditingController();
  final TextEditingController humiditiyTextController = TextEditingController();
  final TextEditingController temperatureTextController = TextEditingController();
  final TextEditingController dioxTextController = TextEditingController();
  final TextEditingController monoxTextController = TextEditingController();
  final TextEditingController vocsTextController = TextEditingController();
  final TextEditingController pm25TextController = TextEditingController();
  final TextEditingController pm10TextController = TextEditingController();
  final TextEditingController commentTextController = TextEditingController();
  final GlobalKey<FormFieldState<String>> buildingDropdownKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> floorDropdownKey =
      GlobalKey<FormFieldState<String>>();

  List<String> autofillPrimaryUse = ['Classroom', 'Storage', 'Boys Bathroom', 'Girls Bathroom', 'Corridor', 'Library', 'Electrical Room', 'Janitor Closet', 'Nurse', 'Office', 'Cafeteria', 'Principal\'s Office', 'Breakroom'];
  bool savedPressed = false;
  late FieldModel showFieldModel = FieldModel();
  late DropdownModel dropdownModel=DropdownModel();
  late FocusNode temperatureFocusNode= FocusNode();

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

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void validateTemperatureAndShowDialog() {
    if (temperatureFocusNode.hasFocus) {
      final temperatureValue = temperatureTextController.text;
      if (temperatureValue.isNotEmpty) {
        final temperature = double.parse(temperatureValue);
        if (temperature > 76 || temperature < 68) {
          _showConfirmValueDialog(context, 'temperature');
        }
      }
    }
  }

  void _saveForm() async {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      buildingDropdownKey.currentState?.reset();
      floorDropdownKey.currentState?.reset();

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
        (commentTextController.text.isNotEmpty)? commentTextController.text : "No issues were observed.",
      ];
      writeIAQ(iaqRoomReadingsRow);
      writeVisualAssessment(visualRoomReadingsRow);

      if (_imageFile != null) {
        await saveImageLocally(_imageFile!, roomNumberTextController.text);
      }
    }
  }

  String? validateRelativeHumidity(String? value) {
    if (value == null) {
      return null;
    } else if (value.isNotEmpty &&
        !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      return "Enter Correct Relative Humidity Value";
    } else {
      return null;
    }
  }

  DropdownButtonFormField buildingDropdownTemplate(
    BuildContext context, DropdownModel model) {
  List<String> options = ['Main', 'Annex', 'Other'];

  return DropdownButtonFormField(
    key: buildingDropdownKey,
    decoration: const InputDecoration(
      labelText: 'Building',
    ),
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
    key: floorDropdownKey,
    decoration: const InputDecoration(
      labelText: 'Floor #',
    ),
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

  @override
  Widget build(BuildContext context) {
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
                    autofillHints: autofillPrimaryUse,
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
                          validator: validateRelativeHumidity,
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

                            if (!seen && (double.parse(value) > 65)) {
                              seen = true;
                              _showConfirmValueDialog(context, 'relative humidity');
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
                          focusNode: temperatureFocusNode,
                          // onChanged: (value) {
                          //   validateTemperatureAndShowDialog();
                          // },
                          decoration: const InputDecoration(
                            labelText: "Temperature (F)",
                            suffixText: 'F',
                          ),
                          onEditingComplete: () {
                            validateTemperatureAndShowDialog();
                            FocusScope.of(context).unfocus();
                          },
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
                      floatingLabelBehavior:FloatingLabelBehavior.always,
                      labelText: "Comments",
                      hintText: 'Enter comments, leave empty if no issues are observed.'
                    ),// Define your text input properties here
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: _getImage,
                    child: const Text('Pick an Image'),
                  ),
                  const SizedBox(
                    height: 20,
                    child: Text("Click image to delete."),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _imageFile = null; // Remove the selected image
                      });
                    },
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            height: 100,
                          )
                        : const Text('No Image Selected'),
                  ),
                  // Save button
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .30,
                    height: MediaQuery.of(context).size.height * .07,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!savedPressed) {
                          if (_formKey.currentState!.validate() &&
                              !(roomNumberTextController.text == '')) {
                            _saveForm();
                            savedPressed = true;
                            roomCount++;
                            debugPrint('room count incremented to= $roomCount');
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
                  if (!autofillPrimaryUse.contains(commentTextController.text)) {
                    autofillPrimaryUse.add(commentTextController.text);
                  }
                  
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
                  buildingDropdownKey.currentState?.reset();
                  floorDropdownKey.currentState?.reset();

                  _imageFile = null;

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
  final iaqPath = prefs.getString('iaqPath')!;
  final iaqCSV = File(iaqPath);
  final iaqContent = await iaqCSV.readAsString();

  // Parse the CSV data
  const csvConverter = CsvToListConverter();
  List<List<dynamic>> iaqData = csvConverter.convert(iaqContent);

  // Check if there are any lines to delete
  if (iaqData.isNotEmpty) {
    // Remove the last line from the data
    iaqData.removeLast();
    // Write the updated data back to the CSV file
    final outputContent = const ListToCsvConverter().convert(iaqData);
    await iaqCSV.writeAsString(outputContent);
  }

  final visualPath = prefs.getString('visualPath')!;
  final visualCSV = File(visualPath);
  final visualContent = await visualCSV.readAsString();

  // Parse the CSV data
  List<List<dynamic>> visualData = csvConverter.convert(visualContent);

  // Check if there are any lines to delete
  if (visualData.isNotEmpty) {
    // Remove the last line from the data
    visualData.removeLast();
    // Write the updated data back to the CSV file
    final outputContent = const ListToCsvConverter().convert(visualData);
    await visualCSV.writeAsString(outputContent);
  }
}

Future<void> writeIAQ(List<dynamic> roomReadingsRow) async {
  final prefs = await SharedPreferences.getInstance();
  final iaqCSV = const ListToCsvConverter().convert([roomReadingsRow]);
  final appDocumentsDirectory = await getApplicationDocumentsDirectory();
  final fileNameBuilder = '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}';

  final iaqDirectory = Directory(path.join(appDocumentsDirectory.path, 'iaQuick', 'csv_files', fileNameBuilder));
  await iaqDirectory.create(recursive: true);
  final iaqFilePath = path.join(iaqDirectory.path, '${fileNameBuilder}_IAQ.csv');
  final file = File(iaqFilePath).openWrite(mode: FileMode.append);
  file.write('\n');
  file.write(iaqCSV);
  await file.close(); // Close the file when done writing
}

Future<void> writeVisualAssessment(List<dynamic> roomReadingsRow) async {
  final prefs = await SharedPreferences.getInstance();
  final visualCSV = const ListToCsvConverter().convert([roomReadingsRow]);
  final appDocumentsDirectory = await getApplicationDocumentsDirectory();
  final fileNameBuilder = '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}';

  final visualDirectory = Directory(path.join(appDocumentsDirectory.path, 'iaQuick', 'csv_files', fileNameBuilder));
  await visualDirectory.create(recursive: true);
  final visualFilePath = path.join(visualDirectory.path, '${fileNameBuilder}_Visual_Assessment.csv');
  final file = File(visualFilePath).openWrite(mode: FileMode.append);
  file.write('\n');
  file.write(visualCSV);
  await file.close(); // Close the file when done writing
}

Future<void> saveImageLocally(File imageFile, String roomNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationDocumentsDirectory();
    final fileNameBuilder = '${prefs.getString('Site Name')!.substring(0, 3)}_${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ') + 1, prefs.getString('Site Name')!.indexOf(' ') + 4)}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0,1)}_${prefs.getString('Last Name')?.substring(0,1)}';

    final localPath = path.join(appDir.path, 'iaQuick', 'csv_files', fileNameBuilder);
    final fileName = '${fileNameBuilder}_room_$roomNumber.jpg'; // You can generate a unique name here

    await imageFile.copy(path.join(localPath, fileName));
    // Store the 'localFile.path' in your form data or database.
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



class DropdownModel {
  String building = '';
  String floor = '';

  DropdownModel({this.building = '', this.floor = ''});
}