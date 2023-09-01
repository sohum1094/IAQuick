import 'package:flutter/material.dart';
import 'user_info_model.dart';

class Result extends StatelessWidget {
  final UserInfoModel model;
  const Result({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(title: const Text('Successful')),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(model.email, style: const TextStyle(fontSize: 22)),
            Text(model.firstName, style: const TextStyle(fontSize: 22)),
            Text(model.lastName, style: const TextStyle(fontSize: 22)),
          ],
        ),
      ),
    ));
  }
}