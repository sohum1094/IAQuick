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
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:iaqapp/main.dart';
import 'package:path/path.dart' as path;
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';

int roomCount = 0;
TextEditingController roomNumberTextController = TextEditingController();
TextEditingController primaryUseTextController = TextEditingController();
TextEditingController humidityTextController = TextEditingController();
TextEditingController temperatureTextController = TextEditingController();
DropdownModel dropdownModel = DropdownModel();

// Add other dropdown controllers and variables here
TextEditingController dioxTextController = TextEditingController();
TextEditingController monoxTextController = TextEditingController();
TextEditingController vocsTextController = TextEditingController();
TextEditingController pm25TextController = TextEditingController();
TextEditingController pm10TextController = TextEditingController();

TextEditingController commentTextController = TextEditingController();

bool savedPressed = false; // Initialize the button state
List<RoomReading> roomReadings = [];

class RoomReadingsFormScreen extends StatelessWidget {
  final SurveyInfo surveyInfo;
  final OutdoorReadings outdoorReadingsInfo;
  final List<File> _imageFiles = [];
  RoomReadingsFormScreen(
      {required this.surveyInfo, required this.outdoorReadingsInfo, super.key});
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
              humidityTextController.clear();
              temperatureTextController.clear();
              //add dropdowns
              dioxTextController.clear();
              monoxTextController.clear();
              vocsTextController.clear();
              pm25TextController.clear();
              pm10TextController.clear();

              commentTextController.clear();

              _imageFiles.clear();

              savedPressed = false;
            }
            if (roomReadings.isNotEmpty) roomReadings.removeLast();
          },
        ),
        title: const Text("Room Readings"),
        centerTitle: true,
      ),
      body: RoomReadingsForm(
          surveyInfo: surveyInfo, outdoorReadingsInfo: outdoorReadingsInfo, imageFiles: _imageFiles),
    );
  }
}

class RoomReadingsForm extends StatefulWidget {
  final SurveyInfo surveyInfo;
  final OutdoorReadings outdoorReadingsInfo;
  final List<File> imageFiles;
  const RoomReadingsForm(
      {required this.surveyInfo, required this.outdoorReadingsInfo, required this.imageFiles, super.key});

  @override
  RoomReadingsFormState createState() => RoomReadingsFormState();
}

class RoomReadingsFormState extends State<RoomReadingsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool visualAssessmentOnly = true; 
  bool outdoorReadingOnly = false;
  final TextEditingController roomNumberTextController =
      TextEditingController();
  final TextEditingController primaryUseTextController =
      TextEditingController();
  final TextEditingController humidityTextController = TextEditingController();
  final TextEditingController temperatureTextController =
      TextEditingController();
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
  bool humidityDialogShown = false;
  bool temperatureDialogShown = false;
  bool co2DialogShown = false;
  bool coDialogShown = false;
  bool pm25DialogShown = false;
  bool pm10DialogShown = false;
  bool vocsDialogShown = false;


  static List<String> autofillPrimaryUse = ['Classroom','Storage','Boys Bathroom','Girls Bathroom','Corridor','Library','Electrical Room','Janitor Closet','Nurse','Office','Cafeteria','Principal\'s Office','Breakroom'];

  bool savedPressed = false;
  late DropdownModel dropdownModel = DropdownModel();
  late FocusNode humidityFocusNode = FocusNode();
  late FocusNode temperatureFocusNode = FocusNode();
  late FocusNode dioxFocusNode = FocusNode();
  late FocusNode monoxFocusNode = FocusNode();
  late FocusNode vocsFocusNode = FocusNode();
  late FocusNode pm25FocusNode = FocusNode();
  late FocusNode pm10FocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    visualAssessmentOnly = true; // Set default to true

    humidityFocusNode.addListener(() {
      if (!humidityFocusNode.hasFocus) validateRelativeHumidityAndShowDialog();
    });
    temperatureFocusNode.addListener(() {
      if (!temperatureFocusNode.hasFocus) validateTemperatureAndShowDialog();
    });
    dioxFocusNode.addListener(() {
      if (!dioxFocusNode.hasFocus) validateDioxAndShowDialog();
    });
    monoxFocusNode.addListener(() {
      if (!monoxFocusNode.hasFocus) validateMonoxAndShowDialog();
    });
    vocsFocusNode.addListener(() {
      if (!vocsFocusNode.hasFocus) validateVOCsAndShowDialog();
    });
    pm25FocusNode.addListener(() {
      if (!pm25FocusNode.hasFocus) validatePM25AndShowDialog();
    });
    pm10FocusNode.addListener(() {
      if (!pm10FocusNode.hasFocus) validatePM10AndShowDialog();
    });
  }

  @override
  void dispose() {
    humidityFocusNode.dispose();
    temperatureFocusNode.dispose();
    dioxFocusNode.dispose();
    monoxFocusNode.dispose();
    vocsFocusNode.dispose();
    pm25FocusNode.dispose();
    pm10FocusNode.dispose();
    super.dispose();
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      _saveFormData();
      return true;
    }
    _showErrorDialog(
        context, 'Please enter all room info correctly before proceeding.');
    return false;
  }

  void _saveFormData() {
    if (!savedPressed) {
      if (_formKey.currentState!.validate() &&
          !(roomNumberTextController.text == '')) {
        _saveForm();
        savedPressed = true;
      } else {
        _showErrorDialog(
            context, 'Please enter all room info correctly before saving.');
      }
    }
  }

  Future<void> _getImage() async {
    // Show options to the user
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _pickImageFromSource(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _pickImageFromSource(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        // If multiple image selection is enabled, add to the list
        widget.imageFiles.add(File(pickedFile.path));
      });
    }
  }

  void _saveForm() async {
    final form = _formKey.currentState;

    if (roomNumberTextController.text.isNotEmpty &&
        primaryUseTextController.text.isNotEmpty &&
        form!.validate()) {
      form.save();
      print('form save complete');
      buildingDropdownKey.currentState?.reset();
      floorDropdownKey.currentState?.reset();

      // Instantiate RoomReading with the collected data
      if (!visualAssessmentOnly) {
        RoomReading roomReading = RoomReading(
          surveyID: widget.surveyInfo.ID,
          building: dropdownModel.building,
          floorNumber: dropdownModel.floor,
          roomNumber: roomNumberTextController.text,
          primaryUse: primaryUseTextController.text,
          temperature: double.parse(temperatureTextController.text),
          relativeHumidity: double.parse(humidityTextController.text),
          co2: widget.surveyInfo.carbonDioxideReadings
              ? double.tryParse(dioxTextController.text)
              : null,
          co: widget.surveyInfo.carbonMonoxideReadings
              ? double.tryParse(monoxTextController.text)
              : null,
          vocs: widget.surveyInfo.vocs
              ? double.tryParse(vocsTextController.text)
              : null,
          pm25: widget.surveyInfo.pm25
              ? double.tryParse(pm25TextController.text)
              : null,
          pm10: widget.surveyInfo.pm10
              ? double.tryParse(pm10TextController.text)
              : null,
          comments: commentTextController.text.isEmpty
              ? "No issues were observed."
              : commentTextController.text,
        );

        // Add the roomReading to the list of room readings
        roomReadings.add(roomReading);
      }


      // Save the image locally if one is selected
      int photoCounter = 1;


      for (File imageFile in widget.imageFiles) {
        // Save each image with the specific naming convention
        await saveImageLocally(
            imageFile, widget.surveyInfo.siteName, DateFormat('ddMMyy').format(widget.surveyInfo.date), roomNumberTextController.text, photoCounter);
        photoCounter++;
      }

      print('saved ${photoCounter - 1} images for ${widget.surveyInfo.siteName}');

      setState(() {
        widget.imageFiles.clear();
      });


    }
  }

  String? validateRelativeHumidity(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      return "Enter Correct Relative Humidity Value";
    } else if (value != null &&
        value.isNotEmpty &&
        !humidityDialogShown &&
        double.parse(humidityTextController.text) > 65) {
      humidityDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConfirmValueDialog(context, 'relative humidity');
      });
    }
    return null;
  }

  void validateRelativeHumidityAndShowDialog() {
    String value = humidityTextController.text;
    if (value.isNotEmpty &&
        !humidityDialogShown &&
        double.parse(humidityTextController.text) > 65) {
      humidityDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConfirmValueDialog(context, 'relative humidity');
      });
    }
  }

  void validateTemperatureAndShowDialog() {
    final temperatureValue = temperatureTextController.text;
    if (temperatureValue.isNotEmpty && !temperatureDialogShown) {
      final temperature = double.parse(temperatureValue);
      if (temperature > 76 || temperature < 68) {
        temperatureDialogShown = true;
        _showConfirmValueDialog(context, 'temperature');
      }
    }
  }

  void validateDioxAndShowDialog() {
    if (!co2DialogShown &&
        (double.parse(dioxTextController.text) >
                widget.outdoorReadingsInfo.co2! + 700 ||
            double.parse(dioxTextController.text) < 0)) {
      co2DialogShown = true;
      _showConfirmValueDialog(context, 'Carbon Dioxide');
    }
  }

  void validateMonoxAndShowDialog() {
    if (!coDialogShown &&
        (double.parse(monoxTextController.text) > 10 ||
            double.parse(monoxTextController.text) < 0)) {
      coDialogShown = true;
      _showConfirmValueDialog(context, 'Carbon Monoxide');
    }
  }

  void validateVOCsAndShowDialog() {
    if (!vocsDialogShown && double.parse(vocsTextController.text) > 3.0) {
      vocsDialogShown = true;
      _showConfirmValueDialog(context, 'VOCs');
    }
  }

  void validatePM25AndShowDialog() {
    if (!pm25DialogShown && double.parse(pm25TextController.text) > 35) {
      pm25DialogShown = true;
      _showConfirmValueDialog(context, 'PM 2.5');
    }
  }

  void validatePM10AndShowDialog() {
    if (!pm10DialogShown && double.parse(pm10TextController.text) > 150) {
      pm10DialogShown = true;
      _showConfirmValueDialog(context, 'PM 10');
    }
  }

  DropdownButtonFormField buildingDropdownTemplate(
      BuildContext context, DropdownModel model) {
    List<String> options = ['Main', 'Annex', 'Modular 1', 'Modular 2', 'Other'];

    return DropdownButtonFormField(
      key: buildingDropdownKey,
      decoration: const InputDecoration(
        labelText: 'Bldg',
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
    List<String> options = ['B','G','1','2','3','4','5','6','7','8','9','10','Other'];

    return DropdownButtonFormField(
      key: floorDropdownKey,
      disabledHint: const Text('Outdoor'),
      decoration: const InputDecoration(
        labelText: 'Fl #',
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

  void resetDialogFlags() {
    humidityDialogShown = false;
    temperatureDialogShown = false;
    co2DialogShown = false;
    coDialogShown = false;
    pm25DialogShown = false;
    pm10DialogShown = false;
    vocsDialogShown = false;
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
                  //Room desc title
                  CheckboxListTile(
                    title: const Text("Outdoor Reading"),
                    value: outdoorReadingOnly,
                    onChanged: (bool? value) {
                      setState(() {
                        outdoorReadingOnly = value ?? true;
                      });
                      if (value != null && value == true) {
                        roomNumberTextController.clear();
                        humidityTextController.clear();
                        temperatureTextController.clear();
                        dioxTextController.clear();
                        monoxTextController.clear();
                        vocsTextController.clear();
                        pm25TextController.clear();
                        pm10TextController.clear();
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
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
                        flex: 4,
                        child: buildingDropdownTemplate(context, dropdownModel),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex: 4,
                        child: floorDropdownTemplate(context, dropdownModel),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      //Room number
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: roomNumberTextController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null) {
                        return null;
                      } else if (value.isNotEmpty &&
                          !RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value)) {
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
                  ), //room readings
                  CheckboxListTile(
                    title: const Text("Visual Assessment Only"),
                    value: visualAssessmentOnly,
                    onChanged: (bool? value) {
                      setState(() {
                        visualAssessmentOnly = value ?? true;
                      });
                      if (value != null && value == true) {
                        humidityTextController.clear();
                        temperatureTextController.clear();
                        dioxTextController.clear();
                        monoxTextController.clear();
                        vocsTextController.clear();
                        pm25TextController.clear();
                        pm10TextController.clear();
                      }
                    },
                  ),
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
                          controller: humidityTextController,
                          enabled: !visualAssessmentOnly,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: validateRelativeHumidity,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: false),
                          onEditingComplete: () {
                            validateRelativeHumidityAndShowDialog();
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
                          enabled: !visualAssessmentOnly,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: false),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                              return "Enter Valid Temperature Value";
                            }
                            return null;
                          },
                          focusNode: temperatureFocusNode,
                          decoration: const InputDecoration(
                            labelText: "Temperature (F)",
                            suffixText: 'F',
                          ),
                          onEditingComplete: () {
                            validateTemperatureAndShowDialog();
                          },
                          // temperature
                        ),
                      ),
                    ],
                  ),

                  // Conditional text entry fields
                  if (widget.surveyInfo.carbonDioxideReadings)
                    TextFormField(
                      controller: dioxTextController,
                      enabled: !visualAssessmentOnly,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                          return "Enter Correct Carbon Dioxide Value";
                        }
                        return null;
                      },
                      onEditingComplete: () {
                        validateDioxAndShowDialog();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Carbon Dioxide',
                        suffixText: 'PPM',
                      ),
                      // Define your text input properties here
                    ),
                  if (widget.surveyInfo.carbonMonoxideReadings)
                    TextFormField(
                      controller: monoxTextController,
                      enabled: !visualAssessmentOnly,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
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
                        validateMonoxAndShowDialog();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Carbon Monoxide',
                        suffixText: 'PPM',
                      ),

                      // Define your text input properties here
                    ),
                  if (widget.surveyInfo.vocs)
                    TextFormField(
                      controller: vocsTextController,
                      enabled: !visualAssessmentOnly,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
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
                        validateVOCsAndShowDialog();
                      },
                      decoration: const InputDecoration(
                        labelText: 'VOCs',
                        suffixText: 'mg/m^3',
                      ),
                      // Define your text input properties here
                    ),
                  if (widget.surveyInfo.pm25)
                    TextFormField(
                      controller: pm25TextController,
                      enabled: !visualAssessmentOnly,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
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
                        validatePM25AndShowDialog();
                      },
                      decoration: const InputDecoration(
                        labelText: 'PM 2.5',
                        suffixText: 'mg/m^3',
                      ),
                    ),
                  if (widget.surveyInfo.pm10)
                    TextFormField(
                      controller: pm10TextController,
                      enabled: !visualAssessmentOnly,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
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
                        validatePM10AndShowDialog();
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
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Comments",
                        hintText:
                            'Enter comments, leave empty if no issues are observed.'),
                    keyboardType: TextInputType
                        .multiline, // Define your text input properties here
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
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.imageFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        File file = widget.imageFiles[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              // Use Image.file to display the image from a File
                              Image.file(
                                file,
                                width: 100,
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() {
                                    widget.imageFiles.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
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
                  if (_validateAndSaveForm()) {
                    resetDialogFlags();
                    if (!autofillPrimaryUse
                        .contains(primaryUseTextController.text)) {
                      autofillPrimaryUse.add(primaryUseTextController.text);
                    }

                    roomNumberTextController.clear();
                    primaryUseTextController.clear();
                    humidityTextController.clear();
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

                    widget.imageFiles.clear();


                    savedPressed = false;
                  } else {
                    _showErrorDialog(context,
                        'Please fill all fields to save room info before adding new room.');
                  }
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
                  if (_validateAndSaveForm()) {
                    resetDialogFlags();
                    if (_formKey.currentState!.validate() && !savedPressed) {
                      _saveForm();
                    }
                    if (roomNumberTextController.text.isNotEmpty) {
                      saveSurveyToLocalDatabase(
                        widget.surveyInfo,
                        widget.outdoorReadingsInfo,
                        roomReadings,
                      );

                      // Navigate to HomeScreen or another appropriate screen
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  } else {
                    _showErrorDialog(context,
                        'Please fill all fields to save current room info before closing.');
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

Future<void> saveImageLocally(
    File imageFile, String siteName, String date, String roomNumber, int photoCounter) async {
  // final prefs = await SharedPreferences.getInstance();
  final appDir = await getApplicationDocumentsDirectory();
  // final fileNameBuilder =
  //     '${siteName}_IAQ_${prefs.getString('Date Time')}_${prefs.getString('First Name')?.substring(0, 1)}_${prefs.getString('Last Name')?.substring(0, 1)}';

  checkPermissions();
  final localPath =
      path.join(appDir.path, 'iaQuick', '${siteName.replaceAll(" ", "")}-$date-images');
  final fileName =
      '${siteName.replaceAll(" ", "")}_room_${roomNumber}_photo$photoCounter.jpg';
  print("filePath should be ${path.join(localPath, fileName)}");
  copyFile(imageFile.path,path.join(localPath, fileName));
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
              Future.microtask(() => Navigator.of(context).pop());
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

Future<void> saveSurveyToLocalDatabase(SurveyInfo surveyInfo,
    OutdoorReadings outdoorReadings, List<RoomReading> roomReadings) async {
  final db = await DatabaseHelper.instance.database;

  // Start a transaction
  await db.transaction((txn) async {
    await txn.insert('survey_info', surveyInfo.toJson());

    outdoorReadings.surveyID = surveyInfo.ID; // Correctly handle as string
    await txn.insert('outdoor_readings', outdoorReadings.toJson());

    for (var roomReading in roomReadings) {
      roomReading.surveyID = surveyInfo.ID; // Correctly handle as string
      await txn.insert('room_readings', roomReading.toJson());
    }
  });
}

Future<void> checkPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

Future<void> copyFile(String sourcePath, String destinationPath) async {
  try {
    final file = File(sourcePath);
    final destinationDir = Directory(destinationPath);

    // Check if source file exists
    if (!await file.exists()) {
      print('Source file does not exist');
      return;
    }

    // Ensure the destination directory exists
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    // Copy the file
    await file.copy('$destinationPath/${file.uri.pathSegments.last}');
  } catch (e) {
    print('Error during file copy: $e');
  }
}
