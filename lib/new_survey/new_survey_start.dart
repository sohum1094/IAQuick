/// This code snippet is a part of a Flutter application that handles the initial survey information form. It includes form fields for site name, address, date, occupancy type, and checkboxes for different readings. The form data is saved using shared preferences and validated before submission.
///
/// Example Usage:
///
/// // Creating an instance of the SurveyInitialInfoForm
/// final form = SurveyInitialInfoForm();
///
/// // Building the form widget
/// final formWidget = form.build(context);
///
/// // Displaying the form widget
/// return formWidget;
///
/// Inputs:
/// - BuildContext context: The build context of the widget.
/// - SurveyInfoModel model: The model object that holds the survey information.
///
/// Flow:
/// 1. The SurveyInitialInfoForm widget is built, which contains form fields for site name, address, date, occupancy type, and checkboxes for different readings.
/// 2. The form data is validated and saved when the form is submitted.
/// 3. If any field is empty or the form validation fails, an error dialog is shown.
/// 4. If the form is successfully submitted, the survey information is saved using shared preferences.
/// 5. The user is navigated to the LoggedScreen widget.
///
/// Outputs:
/// - The SurveyInitialInfoForm widget is built and displayed.
/// - The form data is saved using shared preferences.
/// - The user is navigated to the LoggedScreen widget.
import 'package:flutter/material.dart';
import 'package:easy_form_kit/easy_form_kit.dart';
import 'package:iaqapp/new_survey/outdoor_readings_screen.dart';
import 'package:iaqapp/new_survey/room_readings.dart';
import 'package:iaqapp/models/survey_info.dart';
import 'package:intl/intl.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:iaqapp/api_keys.dart';
import 'dart:io' show Platform;

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

  @override
  EasyForm build(BuildContext context) {
    model.date = DateTime.now();

    return EasyForm(
      key: _initialSurveyInfoKey,
      onSave: (values, form) async {
        if (values['siteName'].isEmpty ||
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
      },
      onSaved: (response, values, form) {
        if (values['siteName'].isNotEmpty &&
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
                  addressTextFormField(context, model, _addressController),
                  DateTimePicker(model: model),
                  occupancyTypeDropdown(context, model),
                  AllCheckboxes(key: _checkboxesKey),
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
        model.siteName = tempSiteName;
      }
    },
  );
}

EasyTextFormField addressTextFormField(
  BuildContext context,
  SurveyInfo model,
  TextEditingController controller,
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
      // pick your platform-specific key
      final apiKey = Platform.isIOS
          ? ios_google_api_key
          : android_google_api_key;

      return GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        googleAPIKey: apiKey,
        debounceTime: 800,
        isLatLngRequired: false,
        itemClick: (prediction) {
          final description = prediction.description ?? '';
          controller.text = description;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: description.length),
          );
          onChanged(description);
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
    dateInput.text = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EasyTextFormField(
      controller: dateInput,
      initialValue: DateFormat('yMd_hmm').format(DateTime.now()),
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
          // Update the model
          widget.model.date = pickedDate;
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  final reading = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OutdoorReadingsScreen(surveyInfo: surveyInfo),
                    ),
                  );
                  if (reading is RoomReading) {
                    roomReadings.add(reading);
                  }
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RoomReadingsFormScreen(surveyInfo: surveyInfo)),
                    );
                  }
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
  const AllCheckboxes({super.key});

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
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * .35,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              child: Text(
                'Readings to be taken: ',
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 1.1),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 1.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    checkboxTemplate(context, 'Carbon Dioxide'),
                    checkboxTemplate(context, 'Carbon Monoxide'),
                    checkboxTemplate(context, 'VOCs'),
                    checkboxTemplate(context, 'PM2.5'),
                    checkboxTemplate(context, 'PM10'),
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
