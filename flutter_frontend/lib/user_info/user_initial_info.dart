import 'package:flutter/material.dart';
import 'package:iaqapp/models/user_info_model.dart';
import 'package:easy_form_kit/easy_form_kit.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInitialInfo extends StatelessWidget {
  const UserInitialInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('User Info'),
          backgroundColor: Colors.blueGrey,
          centerTitle: true,
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .9,
            child: const Column(
              children: [
                Expanded(
                  flex: 1,
                  child: UserInitialInfoForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserInitialInfoForm extends StatefulWidget {
  const UserInitialInfoForm({super.key});

  @override
  UserInitialInfoFormState createState() => UserInitialInfoFormState();
}

class UserInitialInfoFormState extends State<UserInitialInfoForm> {
  final _initialUserFormKey = GlobalKey<FormState>();
  UserInfoModel model = UserInfoModel();

  @override
  EasyForm build(BuildContext context) {
    return EasyForm(
      key: _initialUserFormKey,
      onSave: (values, form) async {
        if (form.validate()) {
          // Basic frontend validation: non-empty fields
          final response = await http.post(
            Uri.parse('http://localhost:3000/userInfo'),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'email': values['email'],
              'firstName': values['firstName'],
              'lastName': values['lastName'],
            }),
          );

          if (response.statusCode == 200) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoggedScreen()));
          } else {
            _alert(context,
                'Failed to save data'); // Handle errors based on backend response
          }
        } else {
          _alert(context,
              'Please fill all fields correctly'); // Local error handling
        }
      },
      child: Center(
        child: Column(
          children: [
            const Spacer(
              flex: 1,
            ),
            emailTextFormField(context, model),
            firstNameTextFormField(context, model),
            lastNameTextFormField(context, model),
            const Spacer(
              flex: 2,
            ),
            EasyFormSaveButton.text('Save Info'),
            const Spacer(
              flex: 1,
            )
          ],
        ),
      ),
    );
  }
}

EasyTextFormField emailTextFormField(BuildContext context, UserInfoModel model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'email',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null || value.isEmpty) {
        return 'Email is required';  // Ensure email is not empty
      }
      return null;  // No error
    },
    decoration: const InputDecoration(
      suffixIcon: Icon(Icons.email_outlined),
      hintText: 'Enter your email address',
      labelText: 'Email Address *',
    ),
    onSaved: (tempEmail) {
      if (tempEmail != null) {
        model.email = tempEmail;
      }
    },
  );
}

EasyTextFormField firstNameTextFormField(BuildContext context, UserInfoModel model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'firstName',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null || value.isEmpty) {
        return 'First name is required';
      } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
        return "Enter a valid first name";
      }
      return null;
    },
    decoration: const InputDecoration(
      hintText: 'Enter your first name',
      labelText: 'First Name *',
    ),
    onSaved: (tempFName) {
      if (tempFName != null) {
        model.firstName = tempFName; // assuming there is a firstName field in model
      }
    },
  );
}

EasyTextFormField lastNameTextFormField(BuildContext context, UserInfoModel model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'lastName',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null || value.isEmpty) {
        return 'Last name is required';
      } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
        return "Enter a valid last name";
      }
      return null;
    },
    decoration: const InputDecoration(
      hintText: 'Enter your last name',
      labelText: 'Last Name *',
    ),
    onSaved: (tempLName) {
      if (tempLName != null) {
        model.lastName = tempLName; // assuming there is a lastName field in model
      }
    },
  );
}


Future<void> _alert(BuildContext context, String text) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(text),
    ),
  );
}

class LoggedScreen extends StatelessWidget {
  const LoggedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Succesfully Saved User Information'),
              const SizedBox(height: 24),
              TextButton(
                child: const Text('Back'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoggedErrorScreen extends StatelessWidget {
  const LoggedErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please fill all fields'),
              const SizedBox(height: 24),
              TextButton(
                child: const Text('Back'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
