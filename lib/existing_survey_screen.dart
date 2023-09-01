import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class ExistingSurveyScreen extends StatefulWidget {
  const ExistingSurveyScreen({Key? key}) : super(key: key);

  @override
  ExistingSurveyScreenState createState() => ExistingSurveyScreenState();
}

class ExistingSurveyScreenState extends State<ExistingSurveyScreen> {
  late TextEditingController searchController;
  List<String> csvFiles = []; // List to store CSV file names

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    loadCsvFiles(); // Load the list of CSV files
  }

  Future<void> loadCsvFiles() async {
    // Get the app's document directory
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    debugPrint(appDocumentsDirectory.toString());
    // Define the CSV files directory within the app's documents directory
    final csvDirectory = Directory('${appDocumentsDirectory.path}/iaQuick/csv_files');

    // Ensure the CSV directory exists, create it if necessary
    if (!csvDirectory.existsSync()) {
      csvDirectory.createSync(recursive: true);
    }

    // Get a list of CSV files in the directory
    final csvFiles = csvDirectory
        .listSync()
        .where((file) => file.path.toLowerCase().endsWith('.csv'))
        .map((file) => file.path)
        .toList();

    setState(() {
      this.csvFiles = csvFiles;
    });
  }

  Future<void> openSelectedFile(BuildContext context, String filePath) async {
    final file = File(filePath);

    if (await file.exists()) {
      // Check if the selected file exists
      // You can implement your logic to open or read the file here
      // For example, you can use the file.readAsString() method to read the file's content
      final fileContent = await file.readAsString();
      debugPrint('File Content:\n$fileContent');
    } else {
      // Handle the case where the file does not exist
      showDialog(
        context: context,
        builder: (context) {
          return  AlertDialog(
            title: const Text('File Not Found'),
            content: const Text('The selected file does not exist.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  List<String> filterCsvFiles(String query) {
    // Filter the CSV files based on the search query
    return csvFiles
        .where((file) => file.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Existing Survey Files'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                setState(() {
                  // Update the list of filtered CSV files when the search query changes
                  csvFiles = filterCsvFiles(query);
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search CSV files...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: csvFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(csvFiles[index]),
                  onTap: () {
                    // Handle file selection here
                    // You can open the selected CSV file or perform any other action
                    openSelectedFile(context, csvFiles[index]);

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(
    home: ExistingSurveyScreen(),
  ));
}
