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
    for (int i = 1; i < csvList.length; i++) {
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

      fileNames.add(
          [siteName, formattedDate, address, iaqPath, visualPath, sourcePath]);
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
                // DataColumn(
                //   label: Expanded(
                //     child: Text('Time'),
                //   ),
                // ),
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
              // final correctedPath = filePath.replaceAll(r'\', '/');
              bool fileExists = await File(filePath).exists();
              debugPrint('File existence: ${fileExists.toString()}');
              final result = await OpenFile.open(filePath);
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
              sendEmail(recentFile);
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
                // DataColumn(
                //   label: Expanded(
                //     child: Text('Time'),
                //   ),
                // ),
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
              // Trigger the Excel creation and email sending process here
              sendEmail(recentFile);
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

Future<List<List<dynamic>>> readCSV(String filePath) async {
  final input = File(filePath).openRead();
  final fields = await input
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .toList();

  return fields;
}

Future<Excel?> writeIAQExcelTemplate(
    String inputFilePath, String outputFileName) async {
  final csvAsList = await readCSV(inputFilePath);
  final directory = await getApplicationDocumentsDirectory();
  final templatePath = File(path.join('assets', 'IAQ_template.xlsx'));
  ByteData templateAsBytes = await rootBundle.load(templatePath.path);

  var bytes = templateAsBytes.buffer.asUint8List(templateAsBytes.offsetInBytes, templateAsBytes.lengthInBytes);
  var excelCopy = Excel.decodeBytes(bytes);

  fillDataInIAQTemplate(excelCopy, csvAsList);


  // final templateFile = File(templatePath.path);
  String formattedOutputFileName = outputFileName.replaceAll(' ', '');
  final outPath = File(path.join(
    directory.path,
    'iaQuick',
    'csv_files',
    'for_export',
    '$formattedOutputFileName.xlsx',
  ));
  await outPath.create(recursive: true);
  // final outputExcel = File(outPath.path);
  // final bytes = await templateFile.readAsBytes();
  // final templateExcel = Excel.decodeBytes(bytes);
  // final outPathToFile = Directory(path.join(outPath.path,'$outputFileName.xlsx')).path;
  // await templateFile.copy(outPathToFile);
  // final excelAsFile = File(outPathToFile);
  // final excelAsBytes = await excelAsFile.readAsBytes();
  // final excel = Excel.decodeBytes(excelAsBytes);
  var outputFileBytes = excelCopy.encode();
  File(outPath.path).writeAsBytesSync(outputFileBytes!);
  return excelCopy;
}

void fillDataInIAQTemplate(Excel excel, List<List<dynamic>> csvData) {
  final table = excel['Entry Sheet'];
  final Map<String, String> columnMapping = {
    'Building': 'Facility Name',
    'Floor #': 'Floor Number',
    'Room #': 'Room Number',
    'Carbon Dioxide (ppm)': 'Carbon Dioxide (ppm)',
    'Primary Room Use': 'Primary Room Use',
    'Temperature (F)': 'Temperature (F)',
    'Relative Humidity (%)': 'Relative Humidity (%)',
    'PM2.5 (mg/m3)': 'PM2.5 (mg/m3)',
    'PM10 (mg/m3)': 'PM10 (mg/m3)',
    'Carbon Monoxide (ppm)': 'Carbon Monoxide (ppm)',
    'VOCs (mg/m3)': 'VOCs (mg/m3)'
  };
  // Assuming you have placeholders in the template (e.g., A1, A2, etc.)
  // Replace these with actual cell names or tags from your template
  String placeholderA2 = 'A2';
  String placeholderB2 = 'B2';
  // Find the cell index in the Excel sheet
  var occupancyCellA2 = table.cell(CellIndex.indexByString(placeholderA2));
  var dateCellB2 = table.cell(CellIndex.indexByString(placeholderB2));
  // Insert data from CSV into the Excel template
  occupancyCellA2.value = csvData[2][0] + ' Occupancy'; // Example: Row 1, Column 1 from CSV
  dateCellB2.value = csvData[1][0]; // Example: Row 1, Column 2 from CSV

  List<String> csvHeaders = csvData[3].cast<String>();

  // Iterate over each row in the CSV data, skipping the header row
  for (int i = 4; i < csvData.length; i++) {
    List<dynamic> row = csvData[i];

    // Iterate over each cell in the row
    for (int j = 0; j < row.length; j++) {
      // Get the CSV column name for this cell
      String csvColumnName = csvHeaders[j];

      // Check if this CSV column has a corresponding Excel column
      if (columnMapping.containsKey(csvColumnName)) {
        // Get the Excel column name
        String excelColumnName = columnMapping[csvColumnName]!;

        // Get the cell in the Excel sheet at the corresponding position
        var cell = table.cell(
            CellIndex.indexByString(excelColumnName + (i + 1).toString()));

        // Set the value of the cell to the value from the CSV data
        cell.value = row[j];
      }
    }
  }

  // Example: Row 1, Column 2 from CSV
}


Future<Excel?> writeVisualExcelTemplate(
    String inputFilePath, String outputFileName) async {
  final csvAsList = await readCSV(inputFilePath);
  final directory = await getApplicationDocumentsDirectory();
  final templatePath = File(path.join('assets', 'Visual_template.xlsx'));

  // Load the Excel template from the assets
  ByteData data = await rootBundle.load(templatePath.path);

  // Decode the Excel file
  var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  var excel = Excel.decodeBytes(bytes);

  // Fill the Excel template with data
  fillDataInVisualTemplate(excel, csvAsList);

  // Save the filled Excel file to the output path
  String formattedOutputFileName = outputFileName.replaceAll(' ', '');
  final outPath = File(path.join(
    directory.path,
    'iaQuick',
    'csv_files',
    'for_export',
    '$formattedOutputFileName.xlsx',
  ));
  await outPath.create(recursive: true);
  var outputFileBytes = excel.encode(); // Encode the filled Excel file to bytes
  File(outPath.path).writeAsBytesSync(outputFileBytes!); // Write the bytes to the output file

  return excel;
}

void fillDataInVisualTemplate(Excel excel, List<List<dynamic>> csvData) {
  final table = excel['Entry Sheet'];
  final Map<String, String> columnMapping = {
    'Building': 'Facility Name',
    'Floor #': 'Floor Number',
    'Room #': 'Room Number',
    'Carbon Dioxide (ppm)': 'Carbon Dioxide (ppm)',
    'Primary Room Use': 'Primary Room Use',
    'Temperature (F)': 'Temperature (F)',
    'Relative Humidity (%)': 'Relative Humidity (%)',
    'Visual Assesment Notes' : 'Comments',
  };
  // Assuming you have placeholders in the template (e.g., A1, A2, etc.)
  // Replace these with actual cell names or tags from your template
  String placeholderA2 = 'A2';
  String placeholderB2 = 'B2';
  // Find the cell index in the Excel sheet
  var occupancyCellA2 = table.cell(CellIndex.indexByString(placeholderA2));
  var dateCellB2 = table.cell(CellIndex.indexByString(placeholderB2));
  // Insert data from CSV into the Excel template
  occupancyCellA2.value = csvData[2][0] + ' Occupancy'; // Example: Row 1, Column 1 from CSV
  dateCellB2.value = csvData[1][0]; // Example: Row 1, Column 2 from CSV

  List<String> csvHeaders = csvData[3].cast<String>();

  // Iterate over each row in the CSV data, skipping the header row
  for (int i = 4; i < csvData.length; i++) {
    List<dynamic> row = csvData[i];

    // Iterate over each cell in the row
    for (int j = 0; j < row.length; j++) {
      // Get the CSV column name for this cell
      String csvColumnName = csvHeaders[j];

      // Check if this CSV column has a corresponding Excel column
      if (columnMapping.containsKey(csvColumnName)) {
        // Get the Excel column name
        String excelColumnName = columnMapping[csvColumnName]!;

        // Get the cell in the Excel sheet at the corresponding position
        var cell = table.cell(
            CellIndex.indexByString(excelColumnName + (i + 1).toString()));

        // Set the value of the cell to the value from the CSV data
        cell.value = row[j];
      }
    }
  }

  // Example: Row 1, Column 2 from CSV
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
  String iaqFilePath =
      File(path.join(outPath.path, '${siteName}_${date}_IAQ.xlsx')).path;
  String visualFilePath =
      File(path.join(outPath.path, '${siteName}_${date}_Visual.xlsx')).path;
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
    ;
  }

  // Create the email
  final Email email = Email(
    body:
        'Hello,\n\nHere are the IAQ and Visual Assesment Files for $siteName recorded on $date created using IAQuick.\n\nPlease review the files before submitting them.\n\nThank you,\nIAQuick',
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
