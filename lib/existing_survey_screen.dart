import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/models.dart' show VisualAssessment, PhotoMetadata;
import 'package:iaqapp/survey_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:image/image.dart' as img_lib;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_keys.dart';


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
              headingRowColor: WidgetStateColor.resolveWith(
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
        DataCell(Text(DateFormat('MM/dd hh:mm a').format(_withCurrentTimeIfMissing(surveyInfo.date))),),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                List<RoomReading> roomReadings =
                    await fetchRoomReadingsForSurvey(surveyInfo.id);
                File iaqExcel =
                    await createIAQExcelFile(surveyInfo, roomReadings);

                List<VisualAssessment> visuals =
                    await fetchVisualAssessmentsForSurvey(surveyInfo.id);
                File visualExcel =
                    await createVisualExcelFile(
                        surveyInfo, visuals, roomReadings);

                final report =
                    await SurveyService().fetchSurveyReport(surveyInfo.id);
                File? photoPdf;
                if (report.photos.isNotEmpty) {
                  photoPdf = await createPhotoPdf(surveyInfo, report.photos);
                }

                File? wordDoc = await generateWordReport(surveyInfo);

                List<String> attachments = [
                  iaqExcel.path,
                  visualExcel.path,
                  if (photoPdf != null) photoPdf.path,
                  if (wordDoc != null) wordDoc.path,
                ];
                await shareFiles(
                    surveyInfo.siteName, surveyInfo.date, attachments);
              } catch (e) {
                // If something fails, log the error and continue
                print('Error exporting survey: $e');
              } finally {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }

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
              headingRowColor: WidgetStateColor.resolveWith(
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
          Text(DateFormat('MM/dd hh:mm a').format(_withCurrentTimeIfMissing(surveyInfo.date))), // Display date
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                List<RoomReading> roomReadings =
                    await fetchRoomReadingsForSurvey(surveyInfo.id);
                File iaqExcel =
                    await createIAQExcelFile(surveyInfo, roomReadings);

                List<VisualAssessment> visuals =
                    await fetchVisualAssessmentsForSurvey(surveyInfo.id);
                File visualExcel =
                    await createVisualExcelFile(
                        surveyInfo, visuals, roomReadings);

                final report =
                    await SurveyService().fetchSurveyReport(surveyInfo.id);
                File? photoPdf;
                if (report.photos.isNotEmpty) {
                  photoPdf = await createPhotoPdf(surveyInfo, report.photos);
                }

                File? wordDoc = await generateWordReport(surveyInfo);

                List<String> attachments = [
                  iaqExcel.path,
                  visualExcel.path,
                  if (photoPdf != null) photoPdf.path,
                  if (wordDoc != null) wordDoc.path,
                ];
                await shareFiles(
                    surveyInfo.siteName, surveyInfo.date, attachments);
              } catch (e) {
                print('Error exporting survey: $e');
              } finally {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
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




Future<void> sendEmail(
    String siteName, DateTime date, List<String> attachmentPaths) async {
  final Email email = Email(
    body:
        "Hello,\n\nHere are the IAQ, Visual Assessment, and Photo files for $siteName recorded on $date created using IAQuick.\n\nPlease review the files before submitting them.\n\nThank you,\nIAQuick",
    subject: 'IAQ, Visual Assessment, and Photo Files for $siteName',
    recipients: [], // Add the recipient's email address here
    attachmentPaths: attachmentPaths,
    isHTML: false,
  );

  // Send the email
  await FlutterEmailSender.send(email);
}


Future<void> shareFiles(
    String siteName, DateTime date, List<String> attachmentPaths) async {
  String message =
      "Hello,\n\nHere are the IAQ, Visual Assessment, and Photo files for $siteName recorded on ${DateFormat('MM-dd-yyyy').format(date)} created using IAQuick.\n\nPlease review the files before submitting them.\n\nThank you,\nIAQuick";

  try {
    final files = attachmentPaths.map((p) => XFile(p)).toList();
    await Share.shareXFiles(
      files,
      text: message,
      subject: '[IAQuick] Report for $siteName is ready',
    );
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
  wb.delete('Sheet1');


  final baseHeaders = [
    'Building',
    'Floor Number',
    'Room Number',
    'Primary Room Use',
    'Temperature (°F)',
    'Relative Humidity (%)',
  ];
  final optionalHeaders = <String>[];
  if (surveyInfo.carbonDioxideReadings) {
    optionalHeaders.add('Carbon Dioxide (ppm)');
  }
  if (surveyInfo.carbonMonoxideReadings) {
    optionalHeaders.add('Carbon Monoxide (ppm)');
  }
  if (surveyInfo.vocs) {
    optionalHeaders.add('VOCs (mg/m³)');
  }
  if (surveyInfo.pm25) {
    optionalHeaders.add('PM2.5 (mg/m³)');
  }
  if (surveyInfo.pm10) {
    optionalHeaders.add('PM10 (mg/m³)');
  }
  final headers = [...baseHeaders, ...optionalHeaders];

  String columnLetter(int index) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var i = index + 1;
    var result = '';
    while (i > 0) {
      i--;
      result = letters[i % 26] + result;
      i ~/= 26;
    }
    return result;
  }

  final lastCol = columnLetter(headers.length - 1);

  sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('${lastCol}1'));
  sheet.cell(CellIndex.indexByString('A1')).value =
      TextCellValue('${surveyInfo.siteName} Indoor Air Quality Measurements');
  sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle();

  sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('${lastCol}2'));
  sheet.cell(CellIndex.indexByString('A2')).value =
      TextCellValue(
          DateFormat('yyyy-MM-dd HH:mm').format(_withCurrentTimeIfMissing(surveyInfo.date)));
  sheet.cell(CellIndex.indexByString('A2')).cellStyle = subHeaderStyle();

  sheet.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('${lastCol}3'));
  final occupancy = surveyInfo.occupancyType == 'Full'
      ? 'Full Occupancy'
      : surveyInfo.occupancyType == 'Partial'
          ? 'Partial Occupancy'
          : surveyInfo.occupancyType;
  sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(occupancy);
  sheet.cell(CellIndex.indexByString('A3')).cellStyle = subHeaderStyle();

  for (var i = 0; i < headers.length; i++) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3));
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = columnHeaderStyle();
  }

  roomReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  final firstOutdoor = roomReadings.indexWhere((r) => r.isOutdoor);
  if (firstOutdoor > 0) {
    final r = roomReadings.removeAt(firstOutdoor);
    roomReadings.insert(0, r);
  }

  final valueAccessors = [
    (RoomReading r) => r.building,
    (RoomReading r) => r.floorNumber,
    (RoomReading r) => r.roomNumber,
    (RoomReading r) => r.primaryUse,
    (RoomReading r) => r.temperature,
    (RoomReading r) => r.relativeHumidity,
  ];
  final decimals = <int?>[null, null, null, null, 1, 1];
  final numberFormats = <NumFormat?>[
    null,
    null,
    null,
    null,
    CustomNumericNumFormat(formatCode: '0.0'),
    CustomNumericNumFormat(formatCode: '0.0'),
  ];
  if (surveyInfo.carbonDioxideReadings) {
    valueAccessors.add((RoomReading r) => r.co2!);
    decimals.add(0);
    numberFormats.add(NumFormat.standard_0);
  }
  if (surveyInfo.carbonMonoxideReadings) {
    valueAccessors.add((RoomReading r) => r.co!);
    decimals.add(0);
    numberFormats.add(NumFormat.standard_0);
  }
  if (surveyInfo.vocs) {
    valueAccessors.add((RoomReading r) => r.vocs!);
    decimals.add(3);
    numberFormats.add(CustomNumericNumFormat(formatCode:'0.000'));
  }
  if (surveyInfo.pm25) {
    valueAccessors.add((RoomReading r) => r.pm25!);
    decimals.add(3);
    numberFormats.add(CustomNumericNumFormat(formatCode:'0.000'));
  }
  if (surveyInfo.pm10) {
    valueAccessors.add((RoomReading r) => r.pm10!);
    decimals.add(3);
    numberFormats.add(CustomNumericNumFormat(formatCode:'0.000'));
  }

  final numericDecimals = decimals.sublist(4);
  final numericFormats = numberFormats.sublist(4);

  for (var i = 0; i < roomReadings.length; i++) {
    final r = roomReadings[i];
    final row = 4 + i;
    for (var c = 0; c < valueAccessors.length; c++) {
      final val = valueAccessors[c](r);
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
      if (val == null) {
        cell.value = null;
      } else if (val is num) {
        final d = decimals[c];
        cell.value = d == null
            ? DoubleCellValue(val.toDouble())
            : DoubleCellValue(double.parse(val.toStringAsFixed(d)));
        final fmt = numberFormats[c];
        if (fmt != null) {
          cell.cellStyle = CellStyle(numberFormat: fmt);
        }
      } else {
        cell.value = TextCellValue(val.toString());
      }
    }
  }

  final indoor = roomReadings.where((r) => !r.isOutdoor).toList();
  final summaryLists = <List<double>>[
    indoor.map((r) => r.temperature).toList(),
    indoor.map((r) => r.relativeHumidity).toList(),
  ];
  if (surveyInfo.carbonDioxideReadings) {
    summaryLists
        .add(indoor.where((r) => r.co2 != null).map((r) => r.co2!).toList());
  }
  if (surveyInfo.carbonMonoxideReadings) {
    summaryLists
        .add(indoor.where((r) => r.co != null).map((r) => r.co!).toList());
  }
  if (surveyInfo.vocs) {
    summaryLists
        .add(indoor.where((r) => r.vocs != null).map((r) => r.vocs!).toList());
  }
  if (surveyInfo.pm25) {
    summaryLists
        .add(indoor.where((r) => r.pm25 != null).map((r) => r.pm25!).toList());
  }
  if (surveyInfo.pm10) {
    summaryLists
        .add(indoor.where((r) => r.pm10 != null).map((r) => r.pm10!).toList());
  }

  final summary = wb['Summary'];
  summary.cell(CellIndex.indexByString('A1')).value = TextCellValue('Minimum');
  summary.cell(CellIndex.indexByString('A2')).value = TextCellValue('Maximum');

  for (var i = 0; i < summaryLists.length; i++) {
    final letter = columnLetter(i + 1); // B, C, D, ...
    final values = summaryLists[i];
    if (values.isNotEmpty) {
      final minCell = summary.cell(CellIndex.indexByString('${letter}1'));
      final maxCell = summary.cell(CellIndex.indexByString('${letter}2'));
      final d = numericDecimals[i];
      final fmt = numericFormats[i];
      minCell.value = d == null
          ? DoubleCellValue(values.reduce(min))
          : DoubleCellValue(double.parse(values.reduce(min).toStringAsFixed(d)));
      maxCell.value = d == null
          ? DoubleCellValue(values.reduce(max))
          : DoubleCellValue(double.parse(values.reduce(max).toStringAsFixed(d)));
      if (fmt != null) {
        minCell.cellStyle = CellStyle(numberFormat: fmt);
        maxCell.cellStyle = CellStyle(numberFormat: fmt);
      }
    } else {
      summary.cell(CellIndex.indexByString('${letter}1')).value = null;
      summary.cell(CellIndex.indexByString('${letter}2')).value = null;
    }
  }

  final bytes = wb.encode();
  final sanitizedProject = sanitizeFileNamePart(surveyInfo.projectNumber);
  final filePath = path.join(
      directory.path,
      'SPC_${surveyInfo.siteName.replaceAll(' ', '_')}_${sanitizedProject}_IAQ_${formatDate(surveyInfo.date)}_${getInspector()}.xlsx');
  final file = File(filePath)..writeAsBytesSync(bytes!);
  return file;
}

Future<File> createPhotoPdf(
  SurveyInfo info,
  List<PhotoMetadata> photos,
) async {
  final pdf = pw.Document();

  // ✅ Use a robust inspector initials fallback:
  String inspector = getInspector();

  final Map<String, List<PhotoMetadata>> byRoom = {};
  for (final p in photos) {
    final key = '${p.building}|${p.roomNumber}';
    byRoom.putIfAbsent(key, () => []).add(p);
  }

  final ttf = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final font = pw.Font.ttf(ttf);

  for (final photo in photos) {
    final key = '${photo.building}|${photo.roomNumber}';
    final list = byRoom[key]!;
    final index = list.indexOf(photo) + 1;
    final total = list.length;


    final rawBytes = await _downloadImageBytes(photo.downloadUrl);
    if (rawBytes.isEmpty) continue;

    final resizedBytes = await resizeImageBytes(rawBytes);
    final image = pw.MemoryImage(resizedBytes);

    final dateTaken = photo.timestamp != null
        ? DateFormat('MM-dd-yyyy HH:mm').format(photo.timestamp!)
        : 'Unknown';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32), // Adds a nice page margin
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                info.siteName,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Building: ${photo.building}', style: pw.TextStyle(font: font)),
              if (photo.floor.isNotEmpty)
                pw.Text('Floor: ${photo.floor}', style: pw.TextStyle(font: font)),
              pw.Text('Room: ${photo.roomNumber}', style: pw.TextStyle(font: font)),
              pw.Text('Image $index of $total', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 12),

              // Use an Expanded Flexible to make the image scale properly
              pw.Expanded(
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Image(
                    image,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),

              pw.SizedBox(height: 12),
              if (inspector.isNotEmpty)
                pw.Text('Inspector: $inspector', style: pw.TextStyle(font: font)),
              pw.Text('Taken: $dateTaken', style: pw.TextStyle(font: font)),
            ],
          );
        },
      ),
    );
  }

  final directory = await getApplicationDocumentsDirectory();
  final sanitizedProject = sanitizeFileNamePart(info.projectNumber);
  final filePath = path.join(
    directory.path,
    'SPC_${info.siteName.replaceAll(' ', '_')}_${sanitizedProject}_Photos_${formatDate(info.date)}_$inspector.pdf',
  );
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());
  return file;
}

Future<File> createVisualExcelFile(
    SurveyInfo surveyInfo, List<VisualAssessment> visuals,
    [List<RoomReading>? roomReadings]) async {
  final directory = await getApplicationDocumentsDirectory();
  final sanitizedProject = sanitizeFileNamePart(surveyInfo.projectNumber);
  final wb = Excel.createExcel();
  final sheet = wb['Visual'];
  wb.delete('Sheet1');

  sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));
  sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('${surveyInfo.siteName} Visual Assessment');
  sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle();

  sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('E2'));
  sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
      DateFormat('yyyy-MM-dd HH:mm').format(_withCurrentTimeIfMissing(surveyInfo.date)));
  sheet.cell(CellIndex.indexByString('A2')).cellStyle = subHeaderStyle();

  sheet.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('E3'));
  final visOcc = surveyInfo.occupancyType == 'Full'
      ? 'Full Occupancy'
      : surveyInfo.occupancyType == 'Partial'
          ? 'Partial Occupancy'
          : surveyInfo.occupancyType;
  sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(visOcc);
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
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = columnHeaderStyle();
  }

  final Map<String, VisualAssessment> visualMap = {
    for (final v in visuals)
      '${v.building}|${v.floorNumber}|${v.roomNumber}': v
  };
  final List<VisualAssessment> rows = [];

  if (roomReadings != null) {
    for (final r in roomReadings) {
      final key = '${r.building}|${r.floorNumber}|${r.roomNumber}';
      if (visualMap.containsKey(key)) {
        rows.add(visualMap.remove(key)!);
      } else {
        rows.add(VisualAssessment(
          building: r.building,
          floorNumber: r.floorNumber,
          roomNumber: r.roomNumber,
          primaryRoomUse: r.primaryUse,
          notes: r.comments.isEmpty ? 'No issues observed.' : r.comments,
        ));
      }
    }
  }

  rows.addAll(visualMap.values);

  for (var i = 0; i < rows.length; i++) {
    final v = rows[i];
    final row = 4 + i;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(v.building);
    final floorCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
    floorCell.value = TextCellValue(v.floorNumber);
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
      'SPC_${surveyInfo.siteName.replaceAll(' ', '_')}_${sanitizedProject}_Visual_${formatDate(surveyInfo.date)}_${getInspector()}.xlsx');
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


CellStyle headerStyle() => CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
      fontSize: 16,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

CellStyle subHeaderStyle() => headerStyle().copyWith(fontSizeVal: 12);

CellStyle columnHeaderStyle() => CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#D9E1F2'),
      horizontalAlign: HorizontalAlign.Center,
    );

DateTime _withCurrentTimeIfMissing(DateTime date) {
  if (date.hour == 0 && date.minute == 0 && date.second == 0) {
    // If no time was recorded with the date, default to midnight. This ensures
    // consistent timestamps across the UI and exported files.
    return DateTime(date.year, date.month, date.day, 0, 0);
  }
  return date;
}

String formatDate(DateTime date) {
  return DateFormat('yyyyMMdd_HHmm').format(_withCurrentTimeIfMissing(date));
}

Future<Uint8List> _downloadImageBytes(String url) async {
  try {
    final ref = FirebaseStorage.instance.refFromURL(url);
    final data = await ref.getData();
    return data ?? Uint8List(0);
  } catch (e) {
    print('Error downloading image $url: $e');
    return Uint8List(0);
  }
}

Future<Uint8List> resizeImageBytes(Uint8List bytes, {int width = 1024}) async {
  final img = img_lib.decodeImage(bytes);
  final resized = img_lib.copyResize(img!, width: width);
  return Uint8List.fromList(img_lib.encodeJpg(resized, quality: 85));
}

String getInspector() {
  final user = FirebaseAuth.instance.currentUser;
  String inspector = '';
  if (user != null) {
    final name = (user.displayName ?? '').trim();
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      final first = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
      final last = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
      inspector = '$first$last'.toUpperCase();
    }
    if (inspector.isEmpty) inspector = (user.email ?? '');
  }
  return inspector;
}



String sanitizeFileNamePart(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
}

Future<File?> generateWordReport(SurveyInfo info) async {
  try {
    final payload = {
      'full_date': DateFormat('MMMM d, yyyy').format(info.date),
      'short_date': DateFormat('M/d/yy').format(info.date),
      'site_name': info.siteName,
      'site_address': info.address,
    };
    print('📤 Sending to generate-iaq-report: $payload');

    final resp = await http.post(
      Uri.parse(generate_report_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception('GCF call failed: ${resp.statusCode}');
    }

    final Map<String, dynamic> result = jsonDecode(resp.body);
    final url = result['url'] as String?;
    if (url == null || url.isEmpty) return null;

    // download via http, not Firebase Storage
    final fileResp = await http.get(Uri.parse(url));
    if (fileResp.statusCode != 200) {
      throw Exception('Download failed: ${fileResp.statusCode}');
    }

    final dir = await getApplicationDocumentsDirectory();
    final safeProject = sanitizeFileNamePart(info.projectNumber);
    final filename = 'SPC_${info.siteName.replaceAll(' ', '_')}_'
        '${safeProject}_Report_${formatDate(info.date)}.docx';
    final file = File(p.join(dir.path, filename));

    await file.writeAsBytes(fileResp.bodyBytes);
    return file;

  } catch (e) {
    print('Error generating Word report: $e');
    return null;
  }
}
