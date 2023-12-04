import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:permission_handler/permission_handler.dart';


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
    // Display the 10 most recent files
    final recentFiles = fileNames.take(10).toList();
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

              ],
              rows: _buildRecentFileRows(recentFiles),
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
          ElevatedButton(
            onPressed: () async {
              








              final result = await OpenFile.open();
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
              






              final result = await OpenFile.open();
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
              // Trigger the Excel creation and email sending process here
              







            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.email),
          ),
        ),
        DataCell(
          Text(siteName), // Display site name
        ),
        DataCell(
          Text(date), // Display date
        ),
        // Add an empty DataCell to match the number of columns
        // DataCell(Container()),
      ]);
    }).toList();
  }

  Widget _searchResultsList() {
    // Display search results here based on searchController.text
    final searchResults = fileNames.where((fileName) => fileName[0]
        .toLowerCase()
        .contains(searchController.text.toLowerCase()));
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
                
              ],
              rows: _buildSearchResultRows(searchResults.toList()),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildSearchResultRows(List<List<String>> recentFiles) {
    return recentFiles.map((recentFile) {
      final siteName = recentFile[0]; // Extract site name
      final date = recentFile[1]; // Extract date

      return DataRow(cells: [
        DataCell(
          ElevatedButton(
            onPressed: () async {
              
              




              final result = await OpenFile.open();
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
             




              final result = await OpenFile.open();
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





            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: const Icon(Icons.email),
          ),
        ),
        DataCell(
          Text(siteName), // Display site name
        ),
        DataCell(
          Text(date), // Display date
        ),
        // Add an empty DataCell to match the number of columns
        // DataCell(Container()),
      ]);
    }).toList();
  }

}




void sendEmail(List<String> recentFile) async {
  // Extract the necessary data from the selected row
  final siteName = recentFile[0];
  final date = recentFile[1].replaceAll("/", "");
  final iaqPath = recentFile[3];
  final visualPath = recentFile[4];


  // Create the Excel files from the CSV data
  Excel? iaqExcel =
      await writeIAQExcelTemplate(iaqPath, '${siteName}_${date}_IAQ');
  Excel? visualExcel =
      await writeVisualExcelTemplate(visualPath, '${siteName}_${date}_Visual');

  final directory = await getApplicationDocumentsDirectory();
  final outPath = Directory(path.join(
    directory.path,
    'iaQuick',
    'csv_files',
    'for_export',
  ));
  await outPath.create(recursive: true);

  // Save the Excel files
    String formattedSiteName = siteName.replaceAll(' ', '');

  String iaqFilePath =
      File(path.join(outPath.path, '${formattedSiteName}_${date}_IAQ.xlsx')).path;
  String visualFilePath =
      File(path.join(outPath.path, '${formattedSiteName}_${date}_Visual.xlsx')).path;
  if (iaqExcel != null) {
    var encoded = iaqExcel.encode();
    if (encoded != null) {
      File(iaqFilePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(encoded);
    }
  }
  if (visualExcel != null) {
    var encoded = visualExcel.encode();
    if (encoded != null) {
      File(visualFilePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(encoded);
    }
  }

  // Create the email
  final Email email = Email(
    body:
        "Hello,\n\nHere are the IAQ and Visual Assesment Files for $siteName recorded on $date created using IAQuick.\n\nPlease review the files before submitting them.\n\nThank you,\nIAQuick",
    subject: 'IAQ and Visual Assesment Excel Files for $siteName',
    recipients: [], // Add the recipient's email address here
    attachmentPaths: [iaqFilePath, visualFilePath],
    isHTML: false,
  );

  // Send the email
  await FlutterEmailSender.send(email);
}

void main() {
  runApp(const MaterialApp(
    home: ExistingSurveyScreen(),
  ));
}
