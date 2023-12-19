
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iaqapp/models/survey_info.dart';

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
  List<DocumentSnapshot> surveyDocuments = [];
  bool showRecentFiles = true;

  @override
  void initState() {
    super.initState();
    _loadSurveyData();
  }

  Future<void> _loadSurveyData() async {
    // Query Firestore for the list of surveys
    var querySnapshot = await FirebaseFirestore.instance.collection('surveys').get();
    surveyDocuments = querySnapshot.docs;

    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchSurveyData() async {
    // Fetch surveys from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('surveys').get();

    // Convert the query results into a list of maps
    List<Map<String, dynamic>> surveys = (querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
    return surveys;
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
   surveyDocuments.sort((a, b) {
    var dataA = a.data() as Map<String, dynamic>?;
    var dataB = b.data() as Map<String, dynamic>?;
    var dateA = dataA != null ? DateTime.parse(dataA['date'] as String) : null;
    var dateB = dataB != null ? DateTime.parse(dataB['date'] as String) : null;
    if (dateA != null && dateB != null) {
      return dateB.compareTo(dateA);
    }
    return 0; // or handle this case appropriately
  });

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
                ),DataColumn(
                  label: Expanded(
                    child: Text('IAQ'),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Visual\nAssesment'),
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
    final recentSurveys = surveyDocuments.take(10).toList();
    return recentSurveys.map((documentSnapshot) {
      final surveyData = documentSnapshot.data() as Map<String, dynamic>;
      final siteName = surveyData['siteName']; // Adjust field names as per your Firestore structure
      final date = surveyData['date']; // Assuming 'date' is stored in a compatible format
  // Extract date
      return DataRow(cells: [
        DataCell(
          Text(siteName), // Display site name
        ),
        DataCell(
          Text(date), // Display date
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              final result = await OpenFile.open( path.join(directory.path, '${siteName}_${date}_IAQ.xlsx'));
              if (result.type == ResultType.done) {
                debugPrint('Opened successfully');
              } else if (result.type == ResultType.noAppToOpen) {
                debugPrint('No app to open this file');
              } else {
                // Error occurred while opening the file
                debugPrint('Error opening the file: ${result.message}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.file_open),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              

              // final result = await OpenFile.open();
              // if (result.type == ResultType.done) {
              //   debugPrint('Opened successfully');
              // } else if (result.type == ResultType.noAppToOpen) {
              //   debugPrint('No app to open this file');
              // } else {
              //   // Error occurred while opening the file
              //   debugPrint('Error opening the file: ${result.message}');
              // }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.file_open),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              // Trigger the Excel creation and email sending process here
              List<RoomReading> roomReadings = await fetchRoomReadingsForSurvey(documentSnapshot.id);
              File iaqExcel = await createIAQExcelFile('${siteName}_${date}_IAQ',surveyData,roomReadings);
              //File visualExcel = await createVisualExcelFile();
              List<String> attachments = [iaqExcel.path, //visualExcel.path
              ];
              sendEmail(siteName, date, attachments);

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
    // Filter the survey documents based on the search query
    final searchResults = surveyDocuments.where((doc) {
      var data = doc.data() as Map<String, dynamic>?;
      return data != null && data['siteName'].toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();

    // Sort the filtered results by date, newest first
    searchResults.sort((a, b) {
      var dataA = a.data() as Map<String, dynamic>;
      var dataB = b.data() as Map<String, dynamic>;
      var dateA = DateTime.parse(dataA['date']);
      var dateB = DateTime.parse(dataB['date']);
      return dateB.compareTo(dateA);
    });

    // Take up to 10 results to display
    final recentFiles = searchResults.take(10).toList();

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
                ),DataColumn(
                  label: Expanded(
                    child: Text('IAQ'),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Visual\nAssessment'),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Export\nto Email'),
                  ),
                ),
                
              ],
              rows: _buildSearchResultRows(recentFiles),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildSearchResultRows(List<DocumentSnapshot<Object?>> documents) {
    return documents.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var siteName = data['siteName'];
      var date = data['date'];
      return DataRow(cells: [
        DataCell(
          Text(siteName), // Display site name
        ),
        DataCell(
          Text(date), // Display date
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              final result = await OpenFile.open( path.join(directory.path, '${siteName}_${date}_IAQ.xlsx'));              
              if (result.type == ResultType.done) {
                debugPrint('opened successfully');
              } else {
                // Unable to open the file
                debugPrint('file not opened properly');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.file_open),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
            

              // final result = await OpenFile.open();
              // if (result.type == ResultType.done) {
              //   debugPrint('opened successfully');
              // } else {
              //   // Unable to open the file
              //   debugPrint('file not opened properly');
              // }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.file_open),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              List<RoomReading> roomReadings = await fetchRoomReadingsForSurvey(doc.id);
              File iaqExcel = await createIAQExcelFile('${siteName}_${date}_IAQ',data,roomReadings);
              //File visualExcel = await createVisualExcelFile();
              List<String> attachments = [iaqExcel.path, //visualExcel.path
              ];
              sendEmail(siteName, date, attachments);

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

  // Create the Excel files from the CSV data
  
  // Excel? visualExcel =
  //     await writeVisualExcelTemplate(visualPath, '${siteName}_${date}_Visual');

  final directory = await getApplicationDocumentsDirectory();
  final outPath = Directory(path.join(
    directory.path,
    'iaQuick',
    'csv_files',
    'for_export',
  ));
  await outPath.create(recursive: true);
  String iaqFilePath = attachmentPaths[0];
  // String visualFilePath = attachmentPaths[1];
  // Create the email
  final Email email = Email(
    body:
        "Hello,\n\nHere are the IAQ and Visual Assesment Files for $siteName recorded on $date created using IAQuick.\n\nPlease review the files before submitting them.\n\nThank you,\nIAQuick",
    subject: 'IAQ and Visual Assesment Excel Files for $siteName',
    recipients: [], // Add the recipient's email address here
    attachmentPaths: [iaqFilePath
    // ,visualFilePath
    ],
    isHTML: false,
  );

  // Send the email
  await FlutterEmailSender.send(email);
}





Future<File> createIAQExcelFile(String fileName, Map<String, dynamic> surveyData, List<RoomReading> roomReadings) async {
  // Get the path to the document directory
  final directory = await getApplicationDocumentsDirectory();
  // Path to the Excel template
  final templatePath = path.join(directory.path, 'IAQ_template_v2.xlsx');
  // Path for the new Excel file
  final newFilePath = path.join(directory.path, '$fileName.xlsx');

  // Read the template
  var excel = Excel.decodeBytes(File(templatePath).readAsBytesSync());

  // Modify the sheet with your data
  var sheet = excel['Data for Print']; // Replace with your actual sheet name
  // Assume 'sheet' is not null
  // Example: Fill in the site name and date
  sheet.cell(CellIndex.indexByString('A1')).value = surveyData['siteName'];
  sheet.cell(CellIndex.indexByString('A2')).value = surveyData['date'];
  sheet.cell(CellIndex.indexByString('A3')).value = surveyData['occupancyType'];

  int startRow = 5;

  for (var reading in roomReadings) {
    // Calculate the row index for each room reading based on startRow
    var rowIndex = startRow + roomReadings.indexOf(reading);

    // Write the room reading data to the corresponding cells
    var cellBuilding = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
    var cellFloorNumber = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
    var cellRoomNumber = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));
    var cellPrimaryUse = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
    var cellTemperature = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));
    var cellRelativeHumidity = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex));
    var cellCO2 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex));
    var cellPM25 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex));
    
    // Assign values from the RoomReading object to the cells
    cellBuilding.value = reading.building;
    cellFloorNumber.value = reading.floorNumber;
    cellRoomNumber.value = reading.roomNumber;
    cellPrimaryUse.value = reading.primaryUse;
    cellTemperature.value = reading.temperature;
    cellRelativeHumidity.value = reading.relativeHumidity;
    cellCO2.value = reading.additionalMetrics['Carbon Dioxide'];
    cellPM25.value = reading.additionalMetrics['PM2.5'];

    // ... Write other additional metrics if needed ...
    
    // Increment the row for the next set of data
    startRow++;
  }

  // Save the filled-in Excel file
  var onValue = excel.encode();
  File(newFilePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(onValue!);

  return File(newFilePath);
}

Future<List<RoomReading>> fetchRoomReadingsForSurvey(String surveyId) async {
  List<RoomReading> roomReadings = [];

  var roomReadingsSnapshot = await FirebaseFirestore.instance
      .collection('surveys')
      .doc(surveyId)
      .collection('roomReadings')
      .get();

  for (var doc in roomReadingsSnapshot.docs) {
    var data = doc.data();
    // Assuming 'RoomReading' has a constructor that accepts a Map
    RoomReading reading = RoomReading.fromMap(data);
    roomReadings.add(reading);
  }

  return roomReadings;
}
