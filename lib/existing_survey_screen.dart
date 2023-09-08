import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class ExistingSurveyScreen extends StatefulWidget {
  const ExistingSurveyScreen({Key? key}) : super(key: key);

  @override
  ExistingSurveyScreenState createState() => ExistingSurveyScreenState();
}

class ExistingSurveyScreenState extends State<ExistingSurveyScreen> {
  TextEditingController searchController = TextEditingController();
  List<List<String>> fileNames = [];
  bool showRecentFiles = true;

  @override
  void initState() {
    super.initState();
    _loadFileNames();
  }

  Future<void> _loadFileNames() async {
    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/iaQuick/csv_files/do_not_edit/survey_meta.csv');

    // Read the CSV file
    final csvString = await file.readAsString();

    // Parse the CSV data into a list of rows
    const csvConverter = CsvToListConverter(eol: '\n');
    final csvList = csvConverter.convert(csvString);

    // Now, each row in csvList should represent a row in your CSV file
    for (int i = 0; i < csvList.length; i++) {
      final row = csvList[i];
      final siteName = row[0];
      final date = row[1];
      final address = row[2];
      final iaqPath = row[3];
      final visualPath = row[4];
      final sourcePath = row[5];

      DateTime dateTime = DateTime.parse(date.toString());

      // Format the DateTime object as 'MM/dd/yyyy'
      String formattedDate = DateFormat('MM/dd/yyyy').format(dateTime);

      fileNames.add([siteName, formattedDate, address, iaqPath,visualPath, sourcePath]);
      // Do something with the extracted metadata and data
    }

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
              headingRowHeight: MediaQuery.of(context).size.height * 0.04,
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
                    child: Text('Site\nFolder'),
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
                DataColumn(
                  label: Expanded(
                    child: Text('Time'),
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

  List<DataRow> _buildRecentFileRows(List<List<String>> recentFiles) {
    return recentFiles.map((recentFile) {
      final siteName = recentFile[0]; // Extract site name
      final date = recentFile[1]; // Extract date

      return DataRow(cells: [
        DataCell(
          ElevatedButton(
            onPressed: () async {
              final filePath = recentFile[3]; // Extract the file path

              // Replace backslashes with forward slashes
              final correctedPath = filePath.replaceAll(r'\', '/');
              bool fileExists = await File(filePath).exists();
              debugPrint('File existence: ${fileExists.toString()}');
              final result = await OpenFile.open(correctedPath);
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
              final filePath = recentFile[4]; // Extract the file path

              // Replace backslashes with forward slashes
              final correctedPath = filePath.replaceAll(r'\', '/');
              bool fileExists = await File(filePath).exists();
              debugPrint('File existence: ${fileExists.toString()}');
              final result = await OpenFile.open(correctedPath);
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
              final filePath = recentFile[5]; // Extract the file path

              // Replace backslashes with forward slashes
              final correctedPath = filePath.replaceAll(r'\', '/');
              bool fileExists = await File(filePath).exists();
              debugPrint('Folder existence: ${fileExists.toString()}');
              final result = await OpenFile.open(correctedPath);
              if (result.type == ResultType.done) {
                debugPrint('Opened successfully');
              } else if (result.type == ResultType.noAppToOpen) {
                debugPrint('No app to open the folder');
              } else {
                // Error occurred while opening the file
                debugPrint('Error opening the folder: ${result.message}');
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
          Text(siteName), // Display site name
        ),
        DataCell(
          Text(date), // Display date
        ),
        // Add an empty DataCell to match the number of columns
        DataCell(Container()),
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
              headingRowHeight: MediaQuery.of(context).size.height * 0.04,
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
                    child: Text('Site\nFolder'),
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
                DataColumn(
                  label: Expanded(
                    child: Text('Time'),
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
              final filePath = recentFile[3]; // Extract the file path
              final result = await OpenFile.open(filePath);
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
              final filePath = recentFile[4]; // Extract the file path
              final result = await OpenFile.open(filePath);
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
              final filePath = recentFile[5]; // Extract the file path
              final result = await OpenFile.open(filePath);
              if (result.type == ResultType.done) {
                debugPrint('opened successfully');
              } else {
                // Unable to open the file
                debugPrint('Folder not opened properly');
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
          Text(siteName), // Display site name
        ),
        DataCell(
          Text(date), // Display date
        ),
        // Add an empty DataCell to match the number of columns
        DataCell(Container()),
      ]);
    }).toList();
  }
}

void main() {
  runApp(const MaterialApp(
    home: ExistingSurveyScreen(),
  ));
}
