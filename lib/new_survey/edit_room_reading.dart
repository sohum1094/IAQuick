import 'package:flutter/material.dart';
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/new_survey/room_readings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iaqapp/utils.dart';
import 'dart:io';

class EditRoomReading extends StatefulWidget {
  final int index;
  final RoomReading roomReading;
  final SurveyInfo surveyInfo;
  const EditRoomReading({
    super.key,
    required this.index,
    required this.roomReading,
    required this.surveyInfo,
  });

  @override
  State<EditRoomReading> createState() => _EditRoomReadingState();
}

class _EditRoomReadingState extends State<EditRoomReading> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController buildingCtrl;
  late final TextEditingController floorCtrl;
  late final TextEditingController roomCtrl;
  late final TextEditingController useCtrl;
  late final TextEditingController tempCtrl;
  late final TextEditingController humidityCtrl;
  late final TextEditingController co2Ctrl;
  late final TextEditingController coCtrl;
  late final TextEditingController vocsCtrl;
  late final TextEditingController pm25Ctrl;
  late final TextEditingController pm10Ctrl;
  late final TextEditingController commentsCtrl;
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    final r = widget.roomReading;
    buildingCtrl = TextEditingController(text: r.building);
    floorCtrl = TextEditingController(text: r.floorNumber);
    roomCtrl = TextEditingController(text: r.roomNumber);
    useCtrl = TextEditingController(text: r.primaryUse);
    tempCtrl = TextEditingController(text: r.temperature.toString());
    humidityCtrl = TextEditingController(text: r.relativeHumidity.toString());
    co2Ctrl = TextEditingController(text: r.co2?.toString() ?? '');
    coCtrl = TextEditingController(text: r.co?.toString() ?? '');
    vocsCtrl = TextEditingController(text: r.vocs?.toString() ?? '');
    pm25Ctrl = TextEditingController(text: r.pm25?.toString() ?? '');
    pm10Ctrl = TextEditingController(text: r.pm10?.toString() ?? '');
    commentsCtrl = TextEditingController(text: r.comments);
    _imageFiles = List<File>.from(r.images);
  }

  @override
  void dispose() {
    buildingCtrl.dispose();
    floorCtrl.dispose();
    roomCtrl.dispose();
    useCtrl.dispose();
    tempCtrl.dispose();
    humidityCtrl.dispose();
    co2Ctrl.dispose();
    coCtrl.dispose();
    vocsCtrl.dispose();
    pm25Ctrl.dispose();
    pm10Ctrl.dispose();
    commentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final status = await Permission.camera.request();
    final picker = ImagePicker();
    XFile? pickedImage;
    if (status.isGranted) {
      pickedImage = await picker.pickImage(source: ImageSource.camera);
    } else if (status.isDenied) {
      pickedImage = await picker.pickImage(source: ImageSource.gallery);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
      return;
    }

    if (pickedImage != null) {
      setState(() {
        _imageFiles.add(File(pickedImage!.path));
      });
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final r = widget.roomReading;
      r.building = buildingCtrl.text;
      r.floorNumber = floorCtrl.text;
      r.roomNumber = roomCtrl.text;
      r.primaryUse = useCtrl.text;
      r.temperature =
          parseFlexibleDouble(tempCtrl.text) ?? r.temperature;
      r.relativeHumidity =
          parseFlexibleDouble(humidityCtrl.text) ?? r.relativeHumidity;
      r.co2 = co2Ctrl.text.isNotEmpty
          ? parseFlexibleDouble(co2Ctrl.text)
          : null;
      r.co = coCtrl.text.isNotEmpty
          ? parseFlexibleDouble(coCtrl.text)
          : null;
      r.vocs = vocsCtrl.text.isNotEmpty
          ? parseFlexibleDouble(vocsCtrl.text)
          : null;
      r.pm25 = pm25Ctrl.text.isNotEmpty
          ? parseFlexibleDouble(pm25Ctrl.text)
          : null;
      r.pm10 = pm10Ctrl.text.isNotEmpty
          ? parseFlexibleDouble(pm10Ctrl.text)
          : null;
      r.comments = commentsCtrl.text;
      r.images = List<File>.from(_imageFiles);
      roomReadings[widget.index] = r;
      Navigator.pop(context);
    }
  }

  void _delete() {
    roomReadings.removeAt(widget.index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Room'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: buildingCtrl,
                decoration: const InputDecoration(labelText: 'Building'),
              ),
              TextFormField(
                controller: floorCtrl,
                decoration: const InputDecoration(labelText: 'Floor #'),
              ),
              TextFormField(
                controller: roomCtrl,
                decoration: const InputDecoration(labelText: 'Room Number'),
              ),
              TextFormField(
                controller: useCtrl,
                decoration: const InputDecoration(labelText: 'Primary Use'),
              ),
              TextFormField(
                controller: tempCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Temperature'),
              ),
              TextFormField(
                controller: humidityCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Relative Humidity'),
              ),
              if (widget.surveyInfo.carbonDioxideReadings)
                TextFormField(
                  controller: co2Ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'CO₂'),
                ),
              if (widget.surveyInfo.carbonMonoxideReadings)
                TextFormField(
                  controller: coCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'CO'),
                ),
              if (widget.surveyInfo.vocs)
                TextFormField(
                  controller: vocsCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'VOCs'),
                ),
              if (widget.surveyInfo.pm25)
                TextFormField(
                  controller: pm25Ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'PM2.5'),
                ),
              if (widget.surveyInfo.pm10)
                TextFormField(
                  controller: pm10Ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'PM10'),
                ),
              TextFormField(
                controller: commentsCtrl,
                decoration: const InputDecoration(labelText: 'Comments'),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _save,
                      child: const Text('Save Room'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _delete,
                      child: const Text('Delete Room'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
