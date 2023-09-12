import 'package:flutter/material.dart';
import 'package:iaqapp/main.dart';

class FileExport extends StatelessWidget {
  const FileExport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Export File"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const HomeScreen();
                },
              ),
            );
          },
        ),
      ),
      body: const Center(
        child: Text("to be created"),
      ),
    );
  }
}
