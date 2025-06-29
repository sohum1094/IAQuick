import 'package:flutter/material.dart';
import 'package:easy_form_kit/easy_form_kit.dart';
import 'package:iaqapp/new_survey/room_readings.dart';
import 'package:iaqapp/models/survey_info.dart';
import 'package:intl/intl.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

String formatSiteName(String input) {
  final words = input.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  final formatted = words.map((word) {
    final first = word[0].toUpperCase();
    final rest = word.length > 1 ? word.substring(1).toLowerCase() : '';
    return '$first$rest';
  }).join(' ');
  return formatted;
}

class NewSurveyStart extends StatelessWidget {
  const NewSurveyStart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('New Survey Information'),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .9,
            child: const Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SurveyInitialInfoForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurveyInitialInfoForm extends StatefulWidget {
  const SurveyInitialInfoForm({super.key});

  @override
  SurveyInitialInfoFormState createState() => SurveyInitialInfoFormState();
}

class SurveyInitialInfoFormState extends State<SurveyInitialInfoForm> {
  final _initialSurveyInfoKey = GlobalKey<FormState>();
  final SurveyInfo model = SurveyInfo();
  final GlobalKey<_AllCheckboxesState> _checkboxesKey =
      GlobalKey<_AllCheckboxesState>();
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

  @override
  EasyForm build(BuildContext context) {
    return EasyForm(
      key: _initialSurveyInfoKey,
      onSave: (values, form) async {
        if (values['siteName'].isEmpty ||
            values['projectNumber'].isEmpty ||
            values['siteAddress'].isEmpty ||
            !form.validate()) {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => errorDialog(context));
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LoggedScreen(surveyInfo: model),
            ),
          );
        }
        model.carbonDioxideReadings =
            _checkboxesKey.currentState!.readingsSwitches['Carbon Dioxide']!;
        model.carbonMonoxideReadings =
            _checkboxesKey.currentState!.readingsSwitches['Carbon Monoxide']!;
        model.vocs = _checkboxesKey.currentState!.readingsSwitches['VOCs']!;
        model.pm25 = _checkboxesKey.currentState!.readingsSwitches['PM2.5']!;
        model.pm10 = _checkboxesKey.currentState!.readingsSwitches['PM10']!;
        model.no2 = _checkboxesKey.currentState!.readingsSwitches['NO2']!;
        model.so2 = _checkboxesKey.currentState!.readingsSwitches['SO2']!;
        model.no = _checkboxesKey.currentState!.readingsSwitches['NO']!;
      },
      onSaved: (response, values, form) {
        if (values['siteName'].isNotEmpty &&
            values['projectNumber'].isNotEmpty &&
            values['siteAddress'].isNotEmpty &&
            form.validate()) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LoggedScreen(surveyInfo: model),
            ),
          );
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .9,
            child: Center(
              child: Column(
                children: [
                  siteNameTextFormField(context, model),
                  projectNumberTextFormField(context, model),
                  addressTextFormField(
                      context, model, _addressController, _addressFocusNode),
                  DateTimePicker(model: model),
                  occupancyTypeDropdown(context, model),
                  AllCheckboxes(key: _checkboxesKey, flex: 2),
                  EasyFormSaveButton.text('Submit'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  AlertDialog errorDialog(BuildContext context) {
    return AlertDialog(
        title: const Text('Error'),
        content: const Text('Please Enter All Fields Correctly'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          )
        ]);
  }
}

EasyTextFormField siteNameTextFormField(
    BuildContext context, SurveyInfo model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'siteName',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null) {
        return null;
      } else if (value.isNotEmpty && !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
        return "Enter Correct Site Name";
      } else {
        return null;
      }
    },
    decoration: const InputDecoration(
      labelText: 'Site Name*',
    ),
    onSaved: (tempSiteName) {
      if (tempSiteName != null) {
        model.siteName = formatSiteName(tempSiteName);
      }
    },
  );
}

EasyTextFormField projectNumberTextFormField(
    BuildContext context, SurveyInfo model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'projectNumber',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null) {
        return null;
      } else if (value.isNotEmpty &&
          !RegExp(r'^[a-zA-Z0-9 _-]+$').hasMatch(value)) {
        return "Enter Correct Project #";
      } else {
        return null;
      }
    },
    decoration: const InputDecoration(
      labelText: 'Project #*',
    ),
    onSaved: (tempProjectNumber) {
      if (tempProjectNumber != null) {
        model.projectNumber = tempProjectNumber;
      }
    },
  );
}

EasyTextFormField addressTextFormField(
  BuildContext context,
  SurveyInfo model,
  TextEditingController controller,
  FocusNode focusNode,
) {
  return EasyTextFormField.builder(
    name: 'siteAddress',
    controller: controller,
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null || value.isEmpty) {
        return 'Enter Correct Site Address';
      }
      return null;
    },
    onSaved: (tempAddress) {
      if (tempAddress != null) model.address = tempAddress;
    },
    builder: (state, onChanged) {
      // pick your platform-specific key from env
      final apiKey = Platform.isIOS
          ? dotenv.env['IOS_GOOGLE_API_KEY']
          : dotenv.env['ANDROID_GOOGLE_API_KEY'];

      return GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        focusNode: focusNode,
        googleAPIKey: apiKey!,
        debounceTime: 800,
        isLatLngRequired: false,
        itemClick: (prediction) async {
          String address = prediction.description ?? '';
          final placeId = prediction.placeId;
          if (placeId != null && placeId.isNotEmpty) {
            final url =
                'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address&key=$apiKey';
            try {
              final resp = await http.get(Uri.parse(url));
              if (resp.statusCode == 200) {
                final data = json.decode(resp.body);
                final formatted = data['result']?['formatted_address'];
                if (formatted is String && formatted.isNotEmpty) {
                  address = formatted.replaceAll(RegExp(r',?\\s*USA\$'), '');
                }
              }
            } catch (_) {}
          }
          controller.text = address;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: address.length),
          );
          onChanged(address);
        },
        inputDecoration: const InputDecoration(
          labelText: 'Street Address*',
        ),
      );
    },
  );
}

class DateTimePicker extends StatefulWidget {
  final SurveyInfo model;
  const DateTimePicker({required this.model, super.key});

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  TextEditingController dateInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    widget.model.date = now;
    dateInput.text = DateFormat('MM-dd-yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return EasyTextFormField(
      controller: dateInput,
      name: 'date',
      autovalidateMode: EasyAutovalidateMode.always,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(
              2000), //DateTime.now() - not to allow to choose before today.
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          // Preserve the selected date but attach the current time so
          // report timestamps reflect the moment the survey was created.
          final now = DateTime.now();
          widget.model.date = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            now.hour,
            now.minute,
          );
          // Set the date in the controller
          dateInput.text = DateFormat('MM-dd-yyyy').format(pickedDate);
        }
      },
      decoration: const InputDecoration(
        labelText: 'Date*',
        suffixIcon: Icon(Icons.calendar_month_outlined),
      ),
    );
  }

  @override
  void dispose() {
    dateInput.dispose();
    super.dispose();
  }
}

class LoggedScreen extends StatelessWidget {
  final SurveyInfo surveyInfo;
  const LoggedScreen({required this.surveyInfo, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Succesfully Saved Survey Info'),
              const SizedBox(height: 24),
              TextButton(
                child: const Text('Next'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RoomReadingsFormScreen(surveyInfo: surveyInfo),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DropdownButtonFormField occupancyTypeDropdown(
    BuildContext context, SurveyInfo model) {
  return DropdownButtonFormField(
    items: const <DropdownMenuItem>[
      DropdownMenuItem(
        value: 'Full',
        child: Text('Full Occupany'),
      ),
      DropdownMenuItem(
        value: 'Partial',
        child: Text('Partial Occupany'),
      ),
      DropdownMenuItem(
        value: 'Vacant',
        child: Text('Vacant'),
      ),
    ],
    onChanged: (value) {
      model.occupancyType = value;
    },
    onSaved: (value) {
      model.occupancyType = value;
    },
    validator: (value) {
      if (value.isEmpty) {
        return "can't empty";
      } else {
        return null;
      }
    },
    decoration: const InputDecoration(
      labelText: 'Occupancy*',
    ),
  );
}


class AllCheckboxes extends StatefulWidget {
  final int flex;
  const AllCheckboxes({super.key, this.flex = 1});

  @override
  State<AllCheckboxes> createState() => _AllCheckboxesState();
}

class _AllCheckboxesState extends State<AllCheckboxes> {
  Map<String, bool> readingsSwitches = {
    'Carbon Dioxide': false,
    'Carbon Monoxide': false,
    'VOCs': false,
    'PM2.5': false,
    'PM10': false,
    'NO2': false,
    'SO2': false,
    'NO': false,
  };

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: widget.flex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Readings to be taken: ',
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.1),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.transparent, width: 1.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView(
                  children: [
                    checkboxTemplate(context, 'Carbon Dioxide'),
                    checkboxTemplate(context, 'Carbon Monoxide'),
                    checkboxTemplate(context, 'VOCs'),
                    checkboxTemplate(context, 'PM2.5'),
                    checkboxTemplate(context, 'PM10'),
                    checkboxTemplate(context, 'NO2'),
                    checkboxTemplate(context, 'SO2'),
                    checkboxTemplate(context, 'NO'),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  CheckboxListTile checkboxTemplate(BuildContext context, String readingType) {
    return CheckboxListTile(
      title: Text(readingType),
      value: readingsSwitches[readingType],
      onChanged: (value) {
        setState(() {
          readingsSwitches[readingType] = value!;
        });
      },
    );
  }
}
