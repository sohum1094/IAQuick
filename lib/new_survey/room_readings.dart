import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iaqapp/utils.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:iaqapp/main.dart';
import 'package:path/path.dart' as path;
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/new_survey/room_readings_overview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iaqapp/survey_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

List<RoomReading> roomReadings = [];

class RoomReadingsFormScreen extends StatefulWidget {
  final SurveyInfo surveyInfo;
  const RoomReadingsFormScreen({required this.surveyInfo, super.key});

  @override
  State<RoomReadingsFormScreen> createState() => _RoomReadingsFormScreenState();
}

class _RoomReadingsFormScreenState extends State<RoomReadingsFormScreen> {
  final GlobalKey<RoomReadingsFormState> formKey =
      GlobalKey<RoomReadingsFormState>();

  @override
  void initState() {
    super.initState();
    // When starting a new survey clear any previous readings
    roomReadings.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.list, color: Colors.black),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RoomReadingsOverview(
                  surveyInfo: widget.surveyInfo,
                ),
              ),
            );
            if (!mounted) return;
            setState(() {});
          },
        ),
        title: const Text("Room Readings"),
        centerTitle: true,
      ),
      body: RoomReadingsForm(
        key: formKey,
        surveyInfo: widget.surveyInfo,
      ),
    );
  }
}

class RoomReadingsForm extends StatefulWidget {
  final SurveyInfo surveyInfo;

  const RoomReadingsForm({
    required this.surveyInfo,
    super.key,
  });

  @override
  RoomReadingsFormState createState() => RoomReadingsFormState();
}

class RoomReadingsFormState extends State<RoomReadingsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController roomNumberTextController =
      TextEditingController();
  final TextEditingController primaryUseTextController =
      TextEditingController();
  final TextEditingController humiditiyTextController = TextEditingController();
  final TextEditingController temperatureTextController =
      TextEditingController();
  final TextEditingController dioxTextController = TextEditingController();
  final TextEditingController monoxTextController = TextEditingController();
  final TextEditingController vocsTextController = TextEditingController();
  final TextEditingController pm25TextController = TextEditingController();
  final TextEditingController pm10TextController = TextEditingController();
  final TextEditingController no2TextController = TextEditingController();
  final TextEditingController so2TextController = TextEditingController();
  final TextEditingController noTextController = TextEditingController();
  final TextEditingController commentTextController = TextEditingController();
  final GlobalKey<FormFieldState<String>> buildingDropdownKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> floorDropdownKey =
      GlobalKey<FormFieldState<String>>();
  double? firstOutdoorCO2;

  List<String> autofillPrimaryUse = [
    'Classroom',
    'Storage',
    'Boys Bathroom',
    'Girls Bathroom',
    'Corridor',
    'Library',
    'Electrical Room',
    'Janitor Closet',
    'Nurse',
    'Office',
    'Cafeteria',
    'Principal\'s Office',
    'Breakroom'
  ];
  late DropdownModel dropdownModel = DropdownModel();
  late FocusNode temperatureFocusNode = FocusNode();
  final List<File> _imageFiles = [];
  bool isOutdoorReading = false;

  @override
  void initState() {
    super.initState();
    // Default the first room to an outdoor reading and
    // prompt the user to confirm zero calibration
    if (roomReadings.isEmpty) {
      isOutdoorReading = true;
      dropdownModel.building = 'Outdoor';
      dropdownModel.floor = '-';
      roomNumberTextController.text = '-';
      primaryUseTextController.text = '-';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCalibrationDialog(context);
      });
    }
  }

  Future<ImageSource?> _selectImageSource() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage() async {
    final source = await _selectImageSource();
    if (source == null) return;

    final imagePicker = ImagePicker();

    if (source == ImageSource.camera) {
      final granted = await requestCameraPermission(context);
      if (!granted) return;
    }

    final pickedImage = await imagePicker.pickImage(source: source);

    if (!mounted) return;
    if (pickedImage != null) {
      setState(() {
        _imageFiles.add(File(pickedImage.path));
      });
    }
  }

  void validateTemperatureAndShowDialog() {
    if (!isOutdoorReading && temperatureFocusNode.hasFocus) {
      final temperatureValue = temperatureTextController.text;
      if (temperatureValue.isNotEmpty) {
        final temperature = parseFlexibleDouble(temperatureValue);
        if (temperature != null && (temperature > 76 || temperature < 68)) {
          _showConfirmValueDialog(context, 'temperature');
        }
      }
    }
  }
  void clearFields() {
    roomNumberTextController.clear();
    primaryUseTextController.clear();
    humiditiyTextController.clear();
    temperatureTextController.clear();
    dioxTextController.clear();
    monoxTextController.clear();
    vocsTextController.clear();
    pm25TextController.clear();
    pm10TextController.clear();
    no2TextController.clear();
    so2TextController.clear();
    noTextController.clear();
    commentTextController.clear();
    buildingDropdownKey.currentState?.reset();
    floorDropdownKey.currentState?.reset();
    _imageFiles.clear();
  }

  bool _formHasInput() {
    return roomNumberTextController.text.isNotEmpty ||
        primaryUseTextController.text.isNotEmpty ||
        humiditiyTextController.text.isNotEmpty ||
        temperatureTextController.text.isNotEmpty ||
        dioxTextController.text.isNotEmpty ||
        monoxTextController.text.isNotEmpty ||
        vocsTextController.text.isNotEmpty ||
        pm25TextController.text.isNotEmpty ||
        pm10TextController.text.isNotEmpty ||
        no2TextController.text.isNotEmpty ||
        so2TextController.text.isNotEmpty ||
        noTextController.text.isNotEmpty ||
        commentTextController.text.isNotEmpty ||
        _imageFiles.isNotEmpty;
  }


  void _saveForm() async {
    final form = _formKey.currentState;


    if (form!.validate()) {
      form.save();
      buildingDropdownKey.currentState?.reset();
      floorDropdownKey.currentState?.reset();

      // Instantiate RoomReading with the collected data
      RoomReading roomReading = RoomReading(
        surveyID: widget.surveyInfo.id,
        building:
            isOutdoorReading ? 'Outdoor' : dropdownModel.building,
        floorNumber: isOutdoorReading ? '-' : dropdownModel.floor,
        roomNumber:
            isOutdoorReading ? '-' : roomNumberTextController.text,
        primaryUse:
            isOutdoorReading ? '-' : primaryUseTextController.text,
        temperature:
            parseFlexibleDouble(temperatureTextController.text) ?? 0,
        relativeHumidity:
            parseFlexibleDouble(humiditiyTextController.text) ?? 0,
        co2: widget.surveyInfo.carbonDioxideReadings
            ? parseFlexibleDouble(dioxTextController.text)
            : null,
        co: widget.surveyInfo.carbonMonoxideReadings
            ? parseFlexibleDouble(monoxTextController.text)
            : null,
        vocs: widget.surveyInfo.vocs
            ? parseFlexibleDouble(vocsTextController.text)
            : null,
        pm25: widget.surveyInfo.pm25
            ? parseFlexibleDouble(pm25TextController.text)
            : null,
        pm10: widget.surveyInfo.pm10
            ? parseFlexibleDouble(pm10TextController.text)
            : null,
        no2: widget.surveyInfo.no2
            ? parseFlexibleDouble(no2TextController.text)
            : null,
        so2: widget.surveyInfo.so2
            ? parseFlexibleDouble(so2TextController.text)
            : null,
        no: widget.surveyInfo.no
            ? parseFlexibleDouble(noTextController.text)
            : null,
        comments: commentTextController.text.isEmpty
            ? "No issues were observed."
            : commentTextController.text,
        isOutdoor: isOutdoorReading,
        images: List<File>.from(_imageFiles),
        timestamp: DateTime.now(),
      );

      // Add the roomReading to the list of room readings
      roomReadings.add(roomReading);

      if (roomReading.isOutdoor && roomReading.co2 != null &&
          firstOutdoorCO2 == null) {
        firstOutdoorCO2 = roomReading.co2;
      }

      // Save images for offline upload if any are selected
      if (_imageFiles.isNotEmpty) {
        final service = SurveyService();
        for (final img in _imageFiles) {
          await service.saveRoomImageOffline(
            building: dropdownModel.building,
            floor: dropdownModel.floor,
            surveyId: widget.surveyInfo.id,
            image: img,
            roomNumber: roomNumberTextController.text,
          );
        }
      }
    }
  }

  String? validateRelativeHumidity(String? value) {
    if (value == null) {
      return null;
    } else if (value.isNotEmpty &&
        !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
      return "Enter Correct Relative Humidity Value";
    } else {
      return null;
    }
  }

  DropdownButtonFormField buildingDropdownTemplate(
      BuildContext context, DropdownModel model) {
    List<String> options = [
      'Main',
      'Annex',
      'Modular 1',
      'Modular 2',
      'Other',
      'Outdoor'
    ];

    return DropdownButtonFormField<String>(
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
      value: isOutdoorReading
          ? 'Outdoor'
          : (model.building.isEmpty ? null : model.building),
      onChanged: isOutdoorReading
          ? null
          : (value) {
              model.building = value!;
            },
      disabledHint: Text(model.building.isEmpty ? 'Outdoor' : model.building),
      onSaved: (value) {
        model.building = value!;
      },
    );
  }

  DropdownButtonFormField floorDropdownTemplate(
      BuildContext context, DropdownModel model) {
    List<String> options = [
      '-',
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

    return DropdownButtonFormField<String>(
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
      value: isOutdoorReading
          ? '-'
          : (model.floor.isEmpty ? null : model.floor),
      onChanged: isOutdoorReading
          ? null
          : (value) {
              model.floor = value!;
            },
      disabledHint: Text(model.floor.isEmpty ? '-' : model.floor),
      onSaved: (value) {
        model.floor = value!;
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
            height: MediaQuery.of(context).size.height * .7,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  // Static text and dropdown fields that are always shown
                  //Room desc title
                  // SizedBox(
                  //   height: 20,
                  //   width: MediaQuery.of(context).size.width * .4,
                  //   child: const Center(
                  //     child: Text(
                  //       'Room description',
                  //     ),
                  //   ),
                  // ),
                  CheckboxListTile(
                    title: const Text('Outdoor Reading'),
                    value: isOutdoorReading,
                    onChanged: roomReadings.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              isOutdoorReading = value ?? false;
                              clearFields();
                              if (isOutdoorReading) {
                                dropdownModel.building = 'Outdoor';
                                dropdownModel.floor = '-';
                                roomNumberTextController.text = '-';
                                primaryUseTextController.text = '-';
                              }
                            });
                          },
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
                      //Room nurmber
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: roomNumberTextController,
                          autovalidateMode: AutovalidateMode.always,
                          enabled: !isOutdoorReading,
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
                    keyboardType: TextInputType.text,
                    enabled: !isOutdoorReading,
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: false),
                          onEditingComplete: () {
                            bool seen = false;

                            if (!isOutdoorReading &&
                                !seen &&
                                (parseFlexibleDouble(
                                        humiditiyTextController.text) ??
                                    double.negativeInfinity) >
                                    65) {
                              seen = true;
                              _showConfirmValueDialog(
                                  context, 'relative humidity');
                            }
                          },
                          onChanged: (value) {
                            bool seen = false;

                            if (!isOutdoorReading &&
                                !seen &&
                                (parseFlexibleDouble(value) ??
                                        double.negativeInfinity) >
                                    65) {
                              seen = true;
                              _showConfirmValueDialog(
                                  context, 'relative humidity');
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: false),
                          validator: (value) {
                            if (value == null) {
                              return null;
                            } else if (value.isNotEmpty &&
                                !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
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
                  if (widget.surveyInfo.carbonDioxideReadings)
                    TextFormField(
                      controller: dioxTextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct Carbon Dioxide Value";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        bool seen = false;

                        final co2Value =
                            parseFlexibleDouble(value) ?? double.negativeInfinity;
                        final threshold = firstOutdoorCO2 != null
                            ? firstOutdoorCO2! + 700
                            : 1100;

                        if (!seen && co2Value > threshold) {
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
                  if (widget.surveyInfo.carbonMonoxideReadings)
                    TextFormField(
                      controller: monoxTextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct Carbon Monoxide Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            (parseFlexibleDouble(monoxTextController.text) ??
                                    double.negativeInfinity) >
                                9) {
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
                  if (widget.surveyInfo.vocs)
                    TextFormField(
                      controller: vocsTextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct VOCs Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            (parseFlexibleDouble(vocsTextController.text) ??
                                    double.negativeInfinity) >
                                0.5) {
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
                  if (widget.surveyInfo.pm25)
                    TextFormField(
                      controller: pm25TextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct PM 2.5 Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            (parseFlexibleDouble(pm25TextController.text) ??
                                    double.negativeInfinity) >
                                0.035) {
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
                  if (widget.surveyInfo.pm10)
                    TextFormField(
                      controller: pm10TextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty &&
                            !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct PM10 Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;

                        if (!seen &&
                            (parseFlexibleDouble(pm10TextController.text) ??
                                    double.negativeInfinity) >
                                150) {
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
                  if (widget.surveyInfo.no2)
                    TextFormField(
                      controller: no2TextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty && !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct NO2 Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;
                        if (!seen && (parseFlexibleDouble(no2TextController.text) ?? double.negativeInfinity) > 1.0) {
                          seen = true;
                          _showConfirmValueDialog(context, 'NO2');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'NO2',
                        suffixText: 'PPM',
                      ),
                    ),
                  if (widget.surveyInfo.so2)
                    TextFormField(
                      controller: so2TextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty && !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct SO2 Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;
                        if (!seen && (parseFlexibleDouble(so2TextController.text) ?? double.negativeInfinity) > 1.0) {
                          seen = true;
                          _showConfirmValueDialog(context, 'SO2');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'SO2',
                        suffixText: 'PPM',
                      ),
                    ),
                  if (widget.surveyInfo.no)
                    TextFormField(
                      controller: noTextController,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                      validator: (value) {
                        if (value == null) {
                          return null;
                        } else if (value.isNotEmpty && !RegExp(r'^(?:\d+(?:\.\d+)?|\.\d+)$').hasMatch(value)) {
                          return "Enter Correct NO Value";
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () {
                        bool seen = false;
                        if (!seen && (parseFlexibleDouble(noTextController.text) ?? double.negativeInfinity) > 1.0) {
                          seen = true;
                          _showConfirmValueDialog(context, 'NO');
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'NO',
                        suffixText: 'PPM',
                      ),
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
                    child: const Text('Add Photo'),
                  ),
                  const SizedBox(height: 20),
                  if (_imageFiles.isNotEmpty)
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _imageFiles
                            .reversed
                            .take(3)
                            .map(
                              (file) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Stack(
                                  children: [
                                    Image.file(file, height: 100),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _imageFiles.remove(file);
                                          });
                                        },
                                        child: Container(
                                          color: Colors.black54,
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
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
                onPressed: () async {
                  final valid = _formKey.currentState!.validate() &&
                      roomNumberTextController.text.isNotEmpty;
                  if (valid) {
                    _saveForm();
                    if (!autofillPrimaryUse
                        .contains(primaryUseTextController.text)) {
                      autofillPrimaryUse.add(primaryUseTextController.text);
                    }
                  } else if (_formHasInput()) {
                    final discard = await _showDiscardDialog(context);
                    if (!mounted || !discard) return;
                  }
                  clearFields();
                  if (!mounted) return;
                  setState(() {
                    isOutdoorReading = false;
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .33,
                  height: MediaQuery.of(context).size.height * .07,
                  child: const Center(
                    child: Text(
                      "Add Room",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  bool proceed = true;
                  if (_formKey.currentState!.validate() &&
                      roomNumberTextController.text.isNotEmpty) {
                    _saveForm();
                  } else if (_formHasInput()) {
                    proceed = await _showDiscardDialog(context);
                    if (!mounted) return;
                    if (proceed) {
                      clearFields();
                    }
                  }
                  if (!proceed) return;
                  if (roomReadings.isEmpty) {
                    _showErrorDialog(context,
                        'Please add at least one room before closing.');
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                  await saveSurveyToFirestore(
                    widget.surveyInfo,
                    roomReadings,
                  );
                  await SurveyService().uploadPendingImages();
                  if (!mounted) return;

                  // Navigate to HomeScreen or another appropriate screen
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
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
                      style: TextStyle(color: Colors.white),
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
  @override
  void dispose() {
    roomNumberTextController.dispose();
    primaryUseTextController.dispose();
    humiditiyTextController.dispose();
    temperatureTextController.dispose();
    dioxTextController.dispose();
    monoxTextController.dispose();
    vocsTextController.dispose();
    pm25TextController.dispose();
    pm10TextController.dispose();
    no2TextController.dispose();
    so2TextController.dispose();
    noTextController.dispose();
    commentTextController.dispose();
    temperatureFocusNode.dispose();
    super.dispose();
  }

}


Future<void> saveImageLocally(File imageFile, String roomNumber) async {
  final prefs = await SharedPreferences.getInstance();
  final appDir = await getApplicationDocumentsDirectory();

  // Retrieve values with null checks
  final siteName = prefs.getString('Site Name') ?? '';
  final dateTime = prefs.getString('Date Time') ?? '';
  final user = FirebaseAuth.instance.currentUser;
  final displayName = user?.displayName ?? '';
  String firstInitial = '';
  String lastInitial = '';
  if (displayName.isNotEmpty) {
    final parts = displayName.split(' ');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      firstInitial = parts[0][0];
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      lastInitial = parts[1][0];
    }
  }

  String fileNameBuilder;

  if (siteName.length >= 3 && siteName.contains(' ')) {
    final spaceIndex = siteName.indexOf(' ');
    if (spaceIndex != -1 && siteName.length >= spaceIndex + 4) {
      final firstPart = siteName.substring(0, 3);
      final secondPart = siteName.substring(spaceIndex + 1, spaceIndex + 4);
      if (dateTime.isNotEmpty && firstInitial.isNotEmpty && lastInitial.isNotEmpty) {
        fileNameBuilder =
            '${firstPart}_${secondPart}_IAQ_${dateTime}_${firstInitial}_$lastInitial';
      } else {
        fileNameBuilder = '${firstPart}_${secondPart}_IAQ';
      }
    } else {
      fileNameBuilder =
          dateTime.isNotEmpty ? 'IAQ_$dateTime' : 'IAQ_${DateTime.now().millisecondsSinceEpoch}';
    }
  } else {
    fileNameBuilder =
        dateTime.isNotEmpty ? 'IAQ_$dateTime' : 'IAQ_${DateTime.now().millisecondsSinceEpoch}';
  }

  final localPath =
      path.join(appDir.path, 'iaQuick', 'csv_files', fileNameBuilder);
  final fileName =
      '${fileNameBuilder}_room_$roomNumber.jpg'; // You can generate a unique name here

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

Future<bool> _showDiscardDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Incomplete Room'),
        content: const Text(
            'The current room entry is incomplete. Discard it and continue?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Discard'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: const Text('Edit'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      );
    },
  );
  return result ?? false;
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

void _showCalibrationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Calibration Check'),
        content: const Text(
            'Have you zero-calibrated the IAQ machine before taking readings?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
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

Future<void> saveSurveyToFirestore(
    SurveyInfo surveyInfo, List<RoomReading> roomReadings) async {
  final service = SurveyService();
  await service.saveSurveyToFirestore(
    info: surveyInfo,
    rooms: roomReadings,
  );
}

/// Requests camera permission, showing system dialog or a rationale/settings prompt as needed.
/// 
/// Returns true if permission is granted, false otherwise.
Future<bool> requestCameraPermission(BuildContext context) async {
  // 1️⃣ Check current status
  var status = await Permission.camera.status;
  final alreadyRequested = await wasCameraPermissionRequested();

  // 2️⃣ If permanently denied, prompt user to open Settings
  if (status.isPermanentlyDenied) {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission'),
        content: Text(
          'Camera access has been permanently denied.\n'
          'Please enable it in Settings under “Permissions.”'
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Open Settings'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (open == true) await openAppSettings();
    return false;
  }

  // 3️⃣ If not granted yet, request it (only first time)
  if (!status.isGranted && !alreadyRequested) {
    status = await Permission.camera.request();
    await markCameraPermissionRequested();
  }

  // 4️⃣ Check result
  if (status.isGranted) {
    return true;
  } else {
    // Denied (but not permanent): show a brief message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camera permission denied.')),
    );
    return false;
  }
}