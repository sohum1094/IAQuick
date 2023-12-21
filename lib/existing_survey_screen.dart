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

// import 'package:permission_handler/permission_handler.dart';

    Directory directory = Directory('path');

void main() async {
  directory = await getApplicationDocumentsDirectory();
  
  runApp(const MaterialApp(
    home: ExistingSurveyScreen(),
  ));
}

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
                // DataColumn(
                //   label: Expanded(
                //     child: Text('IAQ'),
                //   ),
                // ),
                // DataColumn(
                //   label: Expanded(
                //     child: Text('Visual\nAssesment'),
                //   ),
                // ),
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
        // DataCell(
        //   ElevatedButton(
        //     onPressed: () async {
        //       final result = await OpenFile.open( path.join(directory.path, '${surveyInfo.siteName.replaceAll(' ', '_')}_${DateFormat('MMddyyyy').format(surveyInfo.date)}_IAQ.xlsx'));
        //       if (result.type == ResultType.done) {
        //         debugPrint('Opened successfully');
        //       } else if (result.type == ResultType.noAppToOpen) {
        //         debugPrint('No app to open this file');
        //       } else {
        //         // Error occurred while opening the file
        //         debugPrint('Error opening the file: ${result.message}');
        //       }
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.grey,
        //       elevation: 0,
        //     ),
        //     child: const Icon(Icons.file_open),
        //   ),
        // ),
        // DataCell(
        //   ElevatedButton(
        //     onPressed: () async {
        //
        //
        //       // final result = await OpenFile.open();
        //       // if (result.type == ResultType.done) {
        //       //   debugPrint('Opened successfully');
        //       // } else if (result.type == ResultType.noAppToOpen) {
        //       //   debugPrint('No app to open this file');
        //       // } else {
        //       //   // Error occurred while opening the file
        //       //   debugPrint('Error opening the file: ${result.message}');
        //       // }
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.grey,
        //       elevation: 0,
        //     ),
        //     child: const Icon(Icons.file_open),
        //   ),
        // ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              // Trigger the Excel creation and email sending process here
              List<RoomReading> roomReadings = await fetchRoomReadingsForSurvey(surveyInfo.id);
              File iaqExcel = await createIAQExcelFile(surveyInfo,roomReadings);
              //File visualExcel = await createVisualExcelFile();
              List<String> attachments = [iaqExcel.path, //visualExcel.path
              ];
              sendEmail(surveyInfo.siteName, surveyInfo.date, attachments);

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
                // DataColumn(
                //   label: Expanded(
                //     child: Text('IAQ'),
                //   ),
                // ),
                // DataColumn(
                //   label: Expanded(
                //     child: Text('Visual\nAssessment'),
                //   ),
                // ),
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
        // DataCell(
        //   ElevatedButton(
        //     onPressed: () async {
        //       final result = await OpenFile.open( path.join(directory.path, '${surveyInfo.siteName.replaceAll(' ', '_')}_${DateFormat('MMddyyyy').format(surveyInfo.date)}_IAQ.xlsx'));
        //       if (result.type == ResultType.done) {
        //         debugPrint('opened successfully');
        //       } else {
        //         // Unable to open the file
        //         debugPrint('file not opened properly');
        //       }
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.grey,
        //       elevation: 0,
        //     ),
        //     child: const Icon(Icons.file_open),
        //   ),
        // ),
        // DataCell(
        //   ElevatedButton(
        //     onPressed: () async {
        //
        //
        //       // final result = await OpenFile.open();
        //       // if (result.type == ResultType.done) {
        //       //   debugPrint('opened successfully');
        //       // } else {
        //       //   // Unable to open the file
        //       //   debugPrint('file not opened properly');
        //       // }
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.grey,
        //       elevation: 0,
        //     ),
        //     child: const Icon(Icons.file_open),
        //   ),
        // ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              List<RoomReading> roomReadings = await fetchRoomReadingsForSurvey(surveyInfo.id);
              File iaqExcel = await createIAQExcelFile(surveyInfo,roomReadings);
              //File visualExcel = await createVisualExcelFile();
              List<String> attachments = [iaqExcel.path, //visualExcel.path
              ];
              sendEmail(surveyInfo.siteName, surveyInfo.date, attachments);

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





Future<File> createIAQExcelFile(SurveyInfo surveyInfo, List<RoomReading> roomReadings) async {
  // Get the path to the document directory
  final directory = await getApplicationDocumentsDirectory();

  // Load the Excel template from assets
  final ByteData data = await rootBundle.load('assets/IAQ_template_v2.xlsx');
  final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  // Decode the bytes to get Excel object
  var excel = Excel.decodeBytes(bytes);

  var sheet = excel['Data for Print']; // Replace with your actual sheet name



  // Modify the sheet with your data
  // Assume 'sheet' is not null
  // Example: Fill in the site name and date
  sheet.cell(CellIndex.indexByString('A1')).value = surveyInfo.siteName;
  sheet.cell(CellIndex.indexByString('A2')).value = surveyInfo.date;
  sheet.cell(CellIndex.indexByString('A3')).value = surveyInfo.occupancyType;

  int startRow = 5;

  for (var reading in roomReadings) {
    int rowIndex = startRow + roomReadings.indexOf(reading);

    // Assign values from the RoomReading object to the cells
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), reading.building);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex), reading.floorNumber);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex), reading.roomNumber);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex), reading.primaryUse);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex), reading.temperature);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex), reading.relativeHumidity);
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex), reading.co2 ?? '');
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex), reading.co ?? '');
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex), reading.pm25 ?? '');
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex), reading.pm10 ?? '');
    sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex), reading.vocs ?? '');
    // sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex), reading.comments ?? '');

    // Increment the row for the next set of data
    startRow++;
  }

  // Path for the new Excel file
  final newFilePath = path.join(directory.path, '${surveyInfo.siteName.replaceAll(' ', '_')}_${DateFormat('MMddyyyy').format(surveyInfo.date)}_IAQ.xlsx');


  // Save the modified Excel file to the document directory
  var onValue = excel.encode();
  File file = File(newFilePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(onValue!);

  return file;
}

Future<List<RoomReading>> fetchRoomReadingsForSurvey(String surveyId) async {
  return await DatabaseHelper.instance.readRoomReadings(surveyId);
}


