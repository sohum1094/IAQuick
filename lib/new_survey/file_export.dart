import 'package:flutter/material.dart';
import 'package:iaqapp/main.dart';

class FileExport extends StatelessWidget {
  const FileExport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Export File"),
        leading: BackButton(
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
      body: const SizedBox(
        child: Text("to be created"),
      ),
    );
  }
}
