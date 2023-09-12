import 'package:flutter/material.dart';
import 'package:iaqapp/user_info/user_info_model.dart';
import 'package:easy_form_kit/easy_form_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        if (values['email'].isEmpty || values['firstName'].isEmpty || values['lastName'].isEmpty || !form.validate()) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoggedErrorScreen(),
            ),
          );
        } else {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('email', values['email']);
          prefs.setString('First Name', values['firstName']);
          prefs.setString('Last Name', values['lastName']);
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              return <String, dynamic>{
                'hasError': false,
              };
            },
          );
        }
      },
      onSaved: (response, values, form) {
        if (response['hasError'] || values['email'].isEmpty || values['firstName'].isEmpty || values['lastName'].isEmpty || !form.validate()) {
          _alert(context, response['error']);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoggedScreen(),
            ),
          );
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

EasyTextFormField emailTextFormField(
    BuildContext context, UserInfoModel model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'email',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
          r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
          r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
          r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
          r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
          r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
          r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
      final regex = RegExp(pattern);
      return value!.isNotEmpty && !regex.hasMatch(value)
          ? 'Enter a valid email address'
          : null;
    },
    decoration: const InputDecoration(
      suffixIcon: Icon(Icons.email_outlined),
      hintText: 'What address should the survey file be sent to?',
      labelText: 'Email Address *',
    ),
    onSaved: (tempEmail) {
      if (tempEmail != null) {
        model.email = tempEmail;
      }
    },
  );
}

EasyTextFormField firstNameTextFormField(
    BuildContext context, UserInfoModel model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'firstName',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null) {
        return null;
      } else if (value.isNotEmpty && !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
        return "Enter Correct First Name";
      } else {
        return null;
      }
    },
    decoration: const InputDecoration(
      hintText: 'Enter first name to name saved files',
      labelText: 'First Name *',
    ),
    onSaved: (tempFName) {
      if (tempFName != null) {
        model.email = tempFName;
      }
    },
  );
}

EasyTextFormField lastNameTextFormField(
    BuildContext context, UserInfoModel model) {
  return EasyTextFormField(
    initialValue: '',
    name: 'lastName',
    autovalidateMode: EasyAutovalidateMode.always,
    validator: (value, [values]) {
      if (value == null) {
        return null;
      } else if (value.isNotEmpty && !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
        return "Enter Correct Last Name";
      } else {
        return null;
      }
    },
    decoration: const InputDecoration(
      hintText: 'Enter last name to name saved files',
      labelText: 'Last Name *',
    ),
    onSaved: (tempLName) {
      if (tempLName != null) {
        model.email = tempLName;
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
