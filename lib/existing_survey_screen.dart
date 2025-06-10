import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:math';
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/models.dart' show VisualAssessment;
import 'package:iaqapp/survey_service.dart';
import 'package:share_plus/share_plus.dart';

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
    final service = SurveyService();
    surveyList = await service.fetchAllSurveys();
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
                DataColumn(
                  label: Expanded(
                    child: Text('Delete'),
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
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _confirmDeleteSurvey(surveyInfo);
            },
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
                DataColumn(
                  label: Expanded(
                    child: Text('Delete'),
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
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _confirmDeleteSurvey(surveyInfo);
            },
          ),
        ),
      ]);
    }).toList();
  }

  Future<void> _confirmDeleteSurvey(SurveyInfo survey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey'),
        content:
            Text('Are you sure you want to delete "${survey.siteName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = SurveyService();
      await service.deleteSurvey(survey.id);
      setState(() {
        surveyList.removeWhere((s) => s.id == survey.id);
      });
    }
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
    final files = attachmentPaths.map((p) => XFile(p)).toList();
    await Share.shareXFiles(files, text: message);
  } catch (e) {
    // Handle error or inform the user
    print('Error sharing files: $e');
  }
}



Future<File> createIAQExcelFile(
    SurveyInfo surveyInfo, List<RoomReading> roomReadings) async {
  final directory = await getApplicationDocumentsDirectory();
  final wb = Excel.createExcel();
  final sheet = wb['IAQ'];

  sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H1'));
  sheet.cell(CellIndex.indexByString('A1')).value =
      '${surveyInfo.siteName} Indoor Air Quality Measurements';
  sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle();

  sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('H2'));
  sheet.cell(CellIndex.indexByString('A2')).value =
      DateFormat('yyyy-MM-dd HH:mm').format(surveyInfo.date);
  sheet.cell(CellIndex.indexByString('A2')).cellStyle = subHeaderStyle();

  sheet.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('H3'));
  sheet.cell(CellIndex.indexByString('A3')).value = surveyInfo.occupancyType;
  sheet.cell(CellIndex.indexByString('A3')).cellStyle = subHeaderStyle();

  final headers = [
    'Building',
    'Floor Number',
    'Room Number',
    'Primary Room Use',
    'Temperature (°F)',
    'Relative Humidity (%)',
    'Carbon Dioxide (ppm)',
    'PM2.5 (mg/m³)'
  ];
  for (var i = 0; i < headers.length; i++) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3));
    cell.value = headers[i];
    cell.cellStyle = columnHeaderStyle();
  }

  for (var i = 0; i < roomReadings.length; i++) {
    final r = roomReadings[i];
    final row = 4 + i;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(r.building);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(r.floorNumber);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue(r.roomNumber);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = TextCellValue(r.primaryUse);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .value = DoubleCellValue(r.temperature);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = DoubleCellValue(r.relativeHumidity);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .value =
            r.co2 != null ? DoubleCellValue(r.co2!) : null;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        .value =
            r.pm25 != null ? DoubleCellValue(r.pm25!) : null;
  }

  final temps = roomReadings.map((r) => r.temperature).toList();
  final hums = roomReadings.map((r) => r.relativeHumidity).toList();
  final co2 = roomReadings.where((r) => r.co2 != null).map((r) => r.co2!).toList();
  final pm25 =
      roomReadings.where((r) => r.pm25 != null).map((r) => r.pm25!).toList();

  final summary = wb['Summary'];
  summary.cell(CellIndex.indexByString('A1')).value = 'Minimum';
  summary.cell(CellIndex.indexByString('B1')).value = temps.reduce(min);
  summary.cell(CellIndex.indexByString('C1')).value = hums.reduce(min);
  summary.cell(CellIndex.indexByString('D1')).value =
      co2.isNotEmpty ? co2.reduce(min) : null;
  summary.cell(CellIndex.indexByString('E1')).value =
      pm25.isNotEmpty ? pm25.reduce(min) : null;

  summary.cell(CellIndex.indexByString('A2')).value = 'Maximum';
  summary.cell(CellIndex.indexByString('B2')).value = temps.reduce(max);
  summary.cell(CellIndex.indexByString('C2')).value = hums.reduce(max);
  summary.cell(CellIndex.indexByString('D2')).value =
      co2.isNotEmpty ? co2.reduce(max) : null;
  summary.cell(CellIndex.indexByString('E2')).value =
      pm25.isNotEmpty ? pm25.reduce(max) : null;

  final bytes = wb.encode();
  final filePath = path.join(
      directory.path,
      '${surveyInfo.siteName.replaceAll(' ', '_')}-IAQ-${formatDate(surveyInfo.date)}.xlsx');
  final file = File(filePath)..writeAsBytesSync(bytes!);
  return file;
}

Future<File> createVisualExcelFile(
    SurveyInfo surveyInfo, List<VisualAssessment> visuals) async {
  final directory = await getApplicationDocumentsDirectory();
  final wb = Excel.createExcel();
  final sheet = wb['Visual'];

  sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));
  sheet.cell(CellIndex.indexByString('A1')).value =
      '${surveyInfo.siteName} Visual Assessment';
  sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle();

  sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('E2'));
  sheet.cell(CellIndex.indexByString('A2')).value =
      DateFormat('yyyy-MM-dd HH:mm').format(surveyInfo.date);
  sheet.cell(CellIndex.indexByString('A2')).cellStyle = subHeaderStyle();

  sheet.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('E3'));
  sheet.cell(CellIndex.indexByString('A3')).value = surveyInfo.occupancyType;
  sheet.cell(CellIndex.indexByString('A3')).cellStyle = subHeaderStyle();

  final headers = [
    'Building',
    'Floor Number',
    'Room Number',
    'Primary Room Use',
    'Visual Assessment Notes'
  ];
  for (var i = 0; i < headers.length; i++) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3));
    cell.value = headers[i];
    cell.cellStyle = columnHeaderStyle();
  }

  for (var i = 0; i < visuals.length; i++) {
    final v = visuals[i];
    final row = 4 + i;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(v.building);
    final floorCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
    floorCell.value =
        v.floorNumber != null ? IntCellValue(v.floorNumber!) : null;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue(v.roomNumber);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = TextCellValue(v.primaryRoomUse);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .value = TextCellValue(v.notes);
  }

  final bytes = wb.encode();
  final filePath = path.join(
      directory.path,
      '${surveyInfo.siteName.replaceAll(' ', '_')}-Visual-${formatDate(surveyInfo.date)}.xlsx');
  final file = File(filePath)..writeAsBytesSync(bytes!);
  return file;
}

Future<List<VisualAssessment>> fetchVisualAssessmentsForSurvey(String surveyId) async {
  final service = SurveyService();
  final report = await service.fetchSurveyReport(surveyId);
  return report.visuals;
}

Future<List<RoomReading>> fetchRoomReadingsForSurvey(String surveyId) async {
  final service = SurveyService();
  return await service.fetchRoomReadings(surveyId);
}

Future<OutdoorReadings?> fetchOutdoorReadingsForSurvey(String surveyId) async {
  final service = SurveyService();
  return await service.fetchOutdoorReadings(surveyId);
}

CellStyle headerStyle() => CellStyle(
      backgroundColorHex: '#4472C4',
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
      fontSize: 16,
      fontColorHex: '#FFFFFF',
      horizontalAlign: HorizontalAlign.Center,
    );

CellStyle subHeaderStyle() => headerStyle().copyWith(fontSize: 12);

CellStyle columnHeaderStyle() => CellStyle(
      bold: true,
      backgroundColorHex: '#D9E1F2',
      horizontalAlign: HorizontalAlign.Center,
    );

String formatDate(DateTime date) => DateFormat('yyyyMMdd_HHmm').format(date);


