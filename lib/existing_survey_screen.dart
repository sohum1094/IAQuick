import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/database_helper.dart';
import 'package:iaqapp/models.dart' show VisualAssessment;
import 'package:iaqapp/survey_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;

class ExistingSurveyScreen extends StatefulWidget {
  const ExistingSurveyScreen({Key? key}) : super(key: key);

  @override
  ExistingSurveyScreenState createState() => ExistingSurveyScreenState();
}

class ExistingSurveyScreenState extends State<ExistingSurveyScreen> {
  TextEditingController searchController = TextEditingController();
  List<SurveyInfo> surveyList = []; // This will hold surveys fetched from SQLite
  bool showRecentFiles = true; 
  @override
  void initState() {
    super.initState();
    _loadSurveyData();
  }

  Future<void> _loadSurveyData() async {
    surveyList = await DatabaseHelper.instance.readAllSurveys();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Existing Survey Files'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                setState(() {
                  if (query.isNotEmpty) {
                    showRecentFiles = false;
                  } else {
                    showRecentFiles = true;
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      showRecentFiles = true;
                    });
                  },
                ),
              ),
            ),
          ),
          showRecentFiles ? _recentFilesList() : _searchResultsList(),
        ],
      ),
    );
  }

  Widget _recentFilesList() {
   // Assuming that 'date' in surveyDocuments can be parsed into DateTime
  // and is in descending order (most recent first)
    surveyList.sort((a, b) => b.date.compareTo(a.date));


  // Take the 10 most recent files
    return Flexible(
      flex: 1,
      child: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.87,
          width: MediaQuery.of(context).size.width * 0.95,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.indigoAccent),
              headingRowHeight: MediaQuery.of(context).size.height * 0.06,
              border: TableBorder.symmetric(
                  outside: const BorderSide(color: Colors.grey, width: 0.5)),
              columns: const <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text('Site'),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Date'),
                  ),
                ),

                DataColumn(
                  label: Expanded(
                    child: Text('Export\nto Email'),
                  ),
                ),
                

              ],
              rows: _buildRecentFileRows(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildRecentFileRows() {
    // Show the most recent documents or limit the number as needed
    final recentSurveys = surveyList.take(10).toList();
    return recentSurveys.map((surveyInfo) {
  // Extract date
      return DataRow(cells: [
        DataCell(Text(surveyInfo.siteName),),
        DataCell(Text(DateFormat('MM-dd-yyyy').format(surveyInfo.date)),),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              List<RoomReading> roomReadings =
                  await fetchRoomReadingsForSurvey(surveyInfo.id);
              File iaqExcel =
                  await createIAQExcelFile(surveyInfo, roomReadings);

              List<VisualAssessment> visuals =
                  await fetchVisualAssessmentsForSurvey(surveyInfo.id);
              File visualExcel =
                  await createVisualExcelFile(surveyInfo, visuals);

              List<String> attachments = [iaqExcel.path, visualExcel.path];
              shareFiles(surveyInfo.siteName, surveyInfo.date, attachments);

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.email),
          ),
        ),
      ]);
    }).toList();
  }

  Widget _searchResultsList() {
    final String query = searchController.text.toLowerCase();
    final searchResults = surveyList.where((survey) {
      return survey.siteName.toLowerCase().contains(query);
    }).toList();

    // Sort the filtered results by date, newest first
    searchResults.sort((a, b) => b.date.compareTo(a.date));

    // Build the widget using the filtered and sorted list
    return Flexible(
      flex: 1,
      child: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.87,
          width: MediaQuery.of(context).size.width * 0.95,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.indigoAccent),
              headingRowHeight: MediaQuery.of(context).size.height * 0.06,
              border: TableBorder.symmetric(
                  outside: const BorderSide(color: Colors.grey, width: 0.5)),
              columns: const <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text('Site'),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Date'),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Export\nto Email'),
                  ),
                ),
                
              ],
              rows: _buildSearchResultRows(searchResults),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildSearchResultRows(List<SurveyInfo> surveys) {
    return surveys.map((surveyInfo) {
      return DataRow(cells: [
        DataCell(
          Text(surveyInfo.siteName), // Display site name
        ),
        DataCell(
          Text(DateFormat('MM-dd-yyyy').format(surveyInfo.date)), // Display date
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              List<RoomReading> roomReadings =
                  await fetchRoomReadingsForSurvey(surveyInfo.id);
              File iaqExcel =
                  await createIAQExcelFile(surveyInfo, roomReadings);

              List<VisualAssessment> visuals =
                  await fetchVisualAssessmentsForSurvey(surveyInfo.id);
              File visualExcel =
                  await createVisualExcelFile(surveyInfo, visuals);

              List<String> attachments = [iaqExcel.path, visualExcel.path];
              shareFiles(surveyInfo.siteName, surveyInfo.date, attachments);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.email),
          ),
        ),
      ]);
    }).toList();
  }

}




Future<void> sendEmail(String siteName, DateTime date, List<String> attachmentPaths) async {
  // Extract the necessary data from the selected row
  // final visualPath = recentFile[4];
  String iaqFilePath = attachmentPaths[0];
  // String visualFilePath = attachmentPaths[1];
  // Create the email
  final Email email = Email(
    body:
        "Hello,\n\nHere are the IAQ and Visual Assessment Files for $siteName recorded on $date created using IAQuick.\n\nPlease review the files before submitting them.\n\nThank you,\nIAQuick",
    subject: 'IAQ and Visual Assessment Excel Files for $siteName',
    recipients: [], // Add the recipient's email address here
    attachmentPaths: [iaqFilePath
    // ,visualFilePath
    ],
    isHTML: false,
  );

  // Send the email
  await FlutterEmailSender.send(email);
}


Future<void> shareFiles(String siteName, DateTime date, List<String> attachmentPaths) async {
  String message = "Hello,\n\nHere are the IAQ and Visual Assessment Files for $siteName recorded on ${DateFormat('MM-dd-yyyy').format(date)} created using IAQuick.\n\nPlease review the files before submitting them.\n\nThank you,\nIAQuick";

  try {
    await Share.shareFiles(attachmentPaths, text: message);
  } catch (e) {
    // Handle error or inform the user
    print('Error sharing files: $e');
  }
}


// Future<File> createIAQExcelFile(SurveyInfo surveyInfo, List<RoomReading> roomReadings) async {
//   // Get the path to the document directory
//   final directory = await getApplicationDocumentsDirectory();
//
//   // Load the Excel template from assets
//   final ByteData data = await rootBundle.load('assets/IAQ_template_v2.xlsx');
//   final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//
//   // Decode the bytes to get Excel object
//   var excel = Excel.decodeBytes(bytes);
//
//   var sheet = excel['Data for Print']; // Replace with your actual sheet name
//
//
//
//   // Modify the sheet with your data
//   // Assume 'sheet' is not null
//   // Example: Fill in the site name and date
//   sheet.cell(CellIndex.indexByString('A1')).value = surveyInfo.siteName;
//   sheet.cell(CellIndex.indexByString('A2')).value = surveyInfo.date;
//   sheet.cell(CellIndex.indexByString('A3')).value = surveyInfo.occupancyType;
//
//   int startRow = 5;
//
//   for (var reading in roomReadings) {
//     int rowIndex = startRow + roomReadings.indexOf(reading);
//
//     // Assign values from the RoomReading object to the cells
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), reading.building);
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex), reading.floorNumber);
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex), reading.roomNumber);
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex), reading.primaryUse);
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex), reading.temperature);
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex), reading.relativeHumidity);
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex), reading.co2 ?? '');
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex), reading.co ?? '');
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex), reading.pm25 ?? '');
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex), reading.pm10 ?? '');
//     sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex), reading.vocs ?? '');
//     // sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex), reading.comments ?? '');
//
//     // Increment the row for the next set of data
//     startRow++;
//   }
//
//   // Path for the new Excel file
//   final newFilePath = path.join(directory.path, '${surveyInfo.siteName.replaceAll(' ', '_')}_${DateFormat('MMddyyyy').format(surveyInfo.date)}_IAQ.xlsx');
//
//
//   // Save the modified Excel file to the document directory
//   var onValue = excel.encode();
//   File file = File(newFilePath)
//     ..createSync(recursive: true)
//     ..writeAsBytesSync(onValue!);
//
//   return file;
// }

Future<File> createIAQExcelFile(SurveyInfo surveyInfo, List<RoomReading> roomReadings) async {
  // Get the template file
  File templateFile = await getIAQTemplateFile();

  // Open the Excel file
  var excel = Excel.decodeBytes(templateFile.readAsBytesSync());

  // Get specific sheet from Excel
  var sheet = excel['Data for Print']; // Replace with your actual sheet name

  // Outdoor readings are used for CO₂ threshold calculations
  OutdoorReadings? outdoor = await DatabaseHelper.instance.readOutdoorReadings(surveyInfo.id);

  // Style to mark values that exceed thresholds
  CellStyle exceedStyle = CellStyle(backgroundColorHex: '#FF0000');

  // Modify the sheet with your data
  sheet.cell(CellIndex.indexByString('A1')).value = surveyInfo.siteName;
  sheet.cell(CellIndex.indexByString('A2')).value = surveyInfo.date;
  sheet.cell(CellIndex.indexByString('A3')).value = surveyInfo.occupancyType;

  int startRow = 5;
  print('entering readings loop');
  for (var reading in roomReadings) {
    int rowIndex = startRow + roomReadings.indexOf(reading);
    print('Writing to file: ' + reading.toJson().toString());
    // Assign values from the RoomReading object to the cells
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), reading.building);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex), reading.floorNumber);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex), reading.roomNumber);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex), reading.primaryUse);

    // Temperature threshold 68-76 °F
    var tempCell = sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex), reading.temperature);
    if (reading.temperature > 76 || reading.temperature < 68) {
      tempCell.cellStyle = exceedStyle;
    }

    // Relative humidity threshold >65%
    var rhCell = sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex), reading.relativeHumidity);
    if (reading.relativeHumidity > 65) {
      rhCell.cellStyle = exceedStyle;
    }

    // CO₂ threshold = outdoor CO₂ + 700ppm, default to 1000ppm if outdoor not found
    var co2Cell = sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex), reading.co2 ?? '');
    double co2Threshold = (outdoor?.co2 ?? 300) + 700;
    if (reading.co2 != null && reading.co2! > co2Threshold) {
      co2Cell.cellStyle = exceedStyle;
    }

    // CO threshold >10ppm
    var coCell = sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex), reading.co ?? '');
    if (reading.co != null && reading.co! > 10) {
      coCell.cellStyle = exceedStyle;
    }

    // PM2.5 threshold >35 mg/m^3
    var pm25Cell = sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex), reading.pm25 ?? '');
    if (reading.pm25 != null && reading.pm25! > 35) {
      pm25Cell.cellStyle = exceedStyle;
    }

    // PM10 threshold >150 mg/m^3
    var pm10Cell = sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex), reading.pm10 ?? '');
    if (reading.pm10 != null && reading.pm10! > 150) {
      pm10Cell.cellStyle = exceedStyle;
    }

    // VOCs threshold >3 mg/m^3
    var vocsCell = sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex), reading.vocs ?? '');
    if (reading.vocs != null && reading.vocs! > 3) {
      vocsCell.cellStyle = exceedStyle;
    }
    // sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex), reading.comments ?? '');

    // Increment the row for the next set of data
    startRow++;
  }
  final String newFilePath = path.join(templateFile.parent.path, '${surveyInfo.siteName.replaceAll(' ', '_')}_${DateFormat('MMddyyyy').format(surveyInfo.date)}_IAQ.xlsx');

  // Save the modified Excel file to a new file
    var onValue = excel.encode();
    File file = File(newFilePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(onValue!);

    return file;
}

Future<File> createVisualExcelFile(
    SurveyInfo surveyInfo, List<VisualAssessment> visuals) async {
  File templateFile = await getVisualTemplateFile();
  var excel = Excel.decodeBytes(templateFile.readAsBytesSync());

  var entrySheet = excel['Entry Sheet'];
  var printSheet = excel['VA for Print'];

  entrySheet.cell(CellIndex.indexByString('A2')).value = surveyInfo.occupancyType;
  entrySheet.cell(CellIndex.indexByString('B2')).value = surveyInfo.date;
  entrySheet.cell(CellIndex.indexByString('D2')).value = surveyInfo.siteName;

  printSheet.cell(CellIndex.indexByString('A2')).value = surveyInfo.date;
  printSheet.cell(CellIndex.indexByString('A3')).value = surveyInfo.occupancyType;

  int startRow = 5;
  for (var va in visuals) {
    int rowIndex = startRow + visuals.indexOf(va);
    printSheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), va.building);
    printSheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex), va.floorNumber);
    printSheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex), va.roomNumber);
    printSheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex), va.primaryRoomUse);
    printSheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex), va.notes);
    startRow++;
  }

  final String newFilePath = path.join(
    templateFile.parent.path,
    '${surveyInfo.siteName.replaceAll(' ', '_')}_${DateFormat('MMddyyyy').format(surveyInfo.date)}_Visual.xlsx',
  );

  var onValue = excel.encode();
  File file = File(newFilePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(onValue!);

  return file;
}

Future<List<VisualAssessment>> fetchVisualAssessmentsForSurvey(String surveyId) async {
  final service = SurveyService();
  final report = await service.fetchSurveyReport(surveyId);
  return report.visuals;
}

Future<File> getVisualTemplateFile() async {
  final ByteData data = await rootBundle.load('assets/Visual_template.xlsx');
  final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  final directory = await getApplicationDocumentsDirectory();
  final String templatePath = path.join(directory.path, 'Visual_template.xlsx');
  final File file = File(templatePath);

  await file.writeAsBytes(bytes);
  return file;
}



Future<List<RoomReading>> fetchRoomReadingsForSurvey(String surveyId) async {
  return await DatabaseHelper.instance.readRoomReadings(surveyId);
}

Future<OutdoorReadings?> fetchOutdoorReadingsForSurvey(String surveyId) async {
  return await DatabaseHelper.instance.readOutdoorReadings(surveyId);
}

Future<File> getIAQTemplateFile() async {
  final ByteData data = await rootBundle.load('assets/IAQ_template_v2.xlsx');
  final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  final directory = await getApplicationDocumentsDirectory();
  final String templatePath = path.join(directory.path, 'IAQ_template_v2.xlsx');
  final File file = File(templatePath);

  await file.writeAsBytes(bytes);
  return file;
}



