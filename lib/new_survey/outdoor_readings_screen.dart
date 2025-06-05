import 'package:easy_form_kit/easy_form_kit.dart';
import 'package:flutter/material.dart';
import 'package:iaqapp/new_survey/new_survey_start.dart';
import 'package:iaqapp/new_survey/room_readings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iaqapp/models/survey_info.dart';


final GlobalKey<EasyDataFormState> formKey = GlobalKey<EasyDataFormState>();

class OutdoorReadingsScreen extends StatelessWidget {
  final SurveyInfo surveyInfo; 

  const OutdoorReadingsScreen({required this.surveyInfo, super.key});
  


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('${surveyInfo.siteName} Outdoor Readings'),
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
                  child: outdoorReadingsInfoForm(context, surveyInfo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget outdoorReadingsInfoForm(BuildContext context, SurveyInfo surveyInfo) {
  final OutdoorReadings outdoorReadings = OutdoorReadings();

  return FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return EasyDataForm(
          key: formKey,
          onSaved: (values, fieldValues, form) {
            if (form.validate()) {
              outdoorReadings.temperature = double.tryParse(fieldValues['Temperature (F)Field']) ?? 0;
              outdoorReadings.relativeHumidity = double.tryParse(fieldValues['Relative Humidity (%)Field']) ?? 0;
              if (surveyInfo.carbonDioxideReadings) outdoorReadings.co2 = double.tryParse(fieldValues['Carbon DioxideField']);
              if(surveyInfo.carbonMonoxideReadings) outdoorReadings.co = double.tryParse(fieldValues['Carbon MonoxideField']);
              if(surveyInfo.vocs) outdoorReadings.vocs = double.tryParse(fieldValues['VOCsField']);
              if(surveyInfo.pm25) outdoorReadings.pm25 = double.tryParse(fieldValues['PM2.5Field']);
              if(surveyInfo.pm10) outdoorReadings.pm10 = double.tryParse(fieldValues['PM10Field']);
            }
          },
          child: Column(
            children: <Widget>[
              outdoorReadingsTextFormFieldTemplate(context, 'Relative Humidity (%)', 1),
              outdoorReadingsTextFormFieldTemplate(context, 'Temperature (F)', 1),
              if (surveyInfo.carbonDioxideReadings) outdoorReadingsTextFormFieldTemplate(context, 'Carbon Dioxide', 4),
              if (surveyInfo.carbonMonoxideReadings) outdoorReadingsTextFormFieldTemplate(context, 'Carbon Monoxide', 4),
              if (surveyInfo.vocs) outdoorReadingsTextFormFieldTemplate(context, 'VOCs', 4),
              if (surveyInfo.pm25) outdoorReadingsTextFormFieldTemplate(context, 'PM2.5', 4),
              if (surveyInfo.pm10) outdoorReadingsTextFormFieldTemplate(context, 'PM10', 4),
              // Save button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          print('Outdoor readings: ');
                          print(surveyInfo.toJson().toString());
                          print(outdoorReadings.toJson().toString());
                          return RoomReadingsFormScreen(surveyInfo: surveyInfo, outdoorReadingsInfo: outdoorReadings);
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
    keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
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
  );
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
