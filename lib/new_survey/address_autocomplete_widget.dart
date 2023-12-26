import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/api_keys.dart'; // Ensure this file securely manages API keys

class AddressAutoCompleteFormField extends StatefulWidget {
  final SurveyInfo model;

  AddressAutoCompleteFormField({required this.model});

  @override
  _AddressAutoCompleteFormFieldState createState() =>
      _AddressAutoCompleteFormFieldState();
}

class _AddressAutoCompleteFormFieldState
    extends State<AddressAutoCompleteFormField> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.model.address;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  _onTextChanged() {
    if (_controller.text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
    } else {
      _getSuggestions(_controller.text);
    }
  }

  Future<void> _getSuggestions(String query) async {
    var url = Uri.parse(
        'https://autocomplete.search.hereapi.com/v1/autocomplete?q=$query&apiKey=$here_api_key&limit=20');
    var response = await http.get(url);
    var json = jsonDecode(response.body);

    List<String> suggestions = [];
    if (json['items'] != null) {
      for (var item in json['items']) {
        suggestions.add(item['address']['label']);
      }
    }

    if (_focusNode.hasFocus) {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(labelText: 'Street Address*'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter Correct Site Address';
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              widget.model.address = value;
            }
          },
        ),
        if (_controller.text.length >2 && _focusNode.hasFocus && _suggestions.isNotEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height * .25,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]),
                  onTap: () {
                    setState(() {
                      _controller.text = _suggestions[index];
                      widget.model.address = _suggestions[index];
                      _suggestions = [];
                      _focusNode.unfocus();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
