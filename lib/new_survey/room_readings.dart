import 'package:easy_form_kit/easy_form_kit.dart';
import 'package:flutter/material.dart';
import 'package:iaqapp/new_survey/new_survey_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'dart:io';

class RoomReadings extends StatelessWidget {
  const RoomReadings({super.key});
  static int roomCounter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              '${SurveyInitialInfoFormState.model.siteName} Room ${roomCounter++} Readings'),
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
                  child: roomReadingsInfoForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget roomReadingsInfoForm(BuildContext context) {
  List<dynamic> headerRow = ['Building','Floor #', 'Room #', 'Primary Room Use', 'Temperature (F)', 'Relative Humidity (%)'];
  List<dynamic> roomReadingsRow = [];

  DropdownModel model = DropdownModel();
  List<Widget> roomReadingsWidgets = [
          
        ];
        debugPrint('checkpoint 1');

          roomReadingsWidgets.add(SizedBox(
              height: MediaQuery.of(context).size.height * .1,
              child: const Text('Enter Room Data'),
            ));
        roomReadingsWidgets.add(buildingDropdownTemplate(context, 'Building', model));
        roomReadingsWidgets.add(floorDropdownTemplate(context, 'Floor Number', model));
        roomReadingsWidgets.add(roomTextFormField(context, 'Room Number', model));
        roomReadingsWidgets.add(primaryUseTextFormField(context, 'Primary Use', model));
        roomReadingsWidgets.add(roomReadingsTextFormFieldTemplate(context, 'Relative Humidity (%)','%', 1));
        roomReadingsWidgets.add(roomReadingsTextFormFieldTemplate(context, 'Temperature (F)', 'F', 1));
  debugPrint('checkpoint A');
  return FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final prefs = snapshot.data!;
        final GlobalKey<FormState> formKey = GlobalKey<FormState>(); 

        (prefs.getBool('Carbon Dioxide') ?? false) ? headerRow.add('Carbon Dioxide (ppm)') : null;
        (prefs.getBool('Carbon Monoxide') ?? false) ? headerRow.add('Carbon Monoxide (ppm)') : null;
        (prefs.getBool('VOCs') ?? false) ? headerRow.add('VOCs (mg/m3)') : null;
        (prefs.getBool('PM2.5') ?? false) ? headerRow.add('PM2.5 (mg/m3)') : null;
        (prefs.getBool('PM10') ?? false) ? headerRow.add('PM10 (mg/m3)') : null;

        if (prefs.getBool('Carbon Dioxide') ?? false){
          debugPrint('checkpoint 2');
          roomReadingsWidgets.add(roomReadingsTextFormFieldTemplate(context, 'Carbon Dioxide','PPM', 4));
        }
        if (prefs.getBool('Carbon Monoxide') ?? false){
          roomReadingsWidgets.add(roomReadingsTextFormFieldTemplate(context, 'Carbon Monoxide','PPM', 4));
        }
        if (prefs.getBool('VOCs') ?? false) {
          roomReadingsWidgets.add(roomReadingsTextFormFieldTemplate(context, 'VOCs','mg/m3', 4));
        }
        if (prefs.getBool('PM2.5') ?? false) {
          roomReadingsWidgets.add(roomReadingsTextFormFieldTemplate(context, 'PM2.5','mg/m3', 4));
        }
        if (prefs.getBool('PM10') ?? false) {
          roomReadingsWidgets.add(roomReadingsTextFormFieldTemplate(context, 'PM10','mg/m3', 4));
        }
        roomReadingsWidgets.add(EasyFormSaveButton.text('Save'));
               

        return EasyForm(
          key: formKey,
          onSaved: (values, fieldValues, form) {
            if(form.validate()) {
              roomReadingsRow.add(model.building);
              roomReadingsRow.add(model.floor);
              roomReadingsRow.add(model.floor);
              roomReadingsRow.add(fieldValues['Relative Humidity (%)Field']);
              roomReadingsRow.add(fieldValues['Temperature (F)Field']);
              if(prefs.getBool('Carbon Dioxide') ?? false) roomReadingsRow.add(fieldValues['Carbon Dioxide (ppm)']);
              if(prefs.getBool('Carbon Monoxide') ?? false) roomReadingsRow.add(fieldValues['Carbon Monoxide (ppm)']);
              if(prefs.getBool('VOCs') ?? false) roomReadingsRow.add(fieldValues['VOCs (mg/m3)']);
              if(prefs.getBool('PM2.5') ?? false) roomReadingsRow.add(fieldValues['PM2.5 (mg/m3)']);
              if(prefs.getBool('PM10') ?? false) roomReadingsRow.add(fieldValues['PM10 (mg/m3)']);

              writeCSV(roomReadingsRow);
            }
          },
          child: Column(
            children: roomReadingsWidgets,
          ),
        );
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}

EasyTextFormField roomReadingsTextFormFieldTemplate(
    BuildContext context, String readingType, String suffix, int digits) {
  return EasyTextFormField(
    name: '${readingType}Field',
    decoration: InputDecoration(
      hintText: 'Enter $readingType',
      suffixText: suffix,
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

EasyTextFormField roomTextFormField(
    BuildContext context, String readingType, DropdownModel model) {
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
          RegExp(r'[^\w\s]').hasMatch(value)) {
        return "Enter Correct $readingType Value";
      } else {
        return null;
      }
    },
  );
}

DropdownButtonFormField buildingDropdownTemplate(
    BuildContext context, String readingType, DropdownModel model) {
    
    List<String> options = ['Main', 'Annex', 'Other'];

    return DropdownButtonFormField(
    decoration: InputDecoration(
      labelText: '$readingType*',
    ),
    validator:(value) {
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
    BuildContext context, String readingType, DropdownModel model) {
    
    List<String> options = ['B', 'G', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Other'];

    return DropdownButtonFormField(
    decoration: InputDecoration(
      labelText: '$readingType*',
    ),
    validator:(value) {
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


Future<void> writeCSV(List<dynamic> data) async {
  final csv = const ListToCsvConverter().convert([data]);
  final prefs = await SharedPreferences.getInstance();
  final file = File('${prefs.getString('Site Name')!.substring(3)}${prefs.getString('Site Name')!.substring(prefs.getString('Site Name')!.indexOf(' ')+1,3)}_IAQ_${prefs.getString('Date Time')}.csv');
  await file.writeAsString(csv);
}

EasyTextFormField primaryUseTextFormField(
    BuildContext context, String readingType, DropdownModel model) {
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
          !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
        return "Enter Correct $readingType Value";
      } else {
        return null;
      }
    },
    onSaved:(newValue) {
      if ( newValue != null && newValue.isNotEmpty &&
          RegExp(r'[^\w\s]').hasMatch(newValue)) {
        model.primaryUse = newValue;
      }
    },
  );
}



class DropdownModel{
  String building = '';
  String floor = '';
  String room = '';
  String primaryUse = '';

  DropdownModel({this.building = '',this.floor= '',this.room= '', this.primaryUse = ''});
}