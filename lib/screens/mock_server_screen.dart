import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/request.dart';
import '../services/firestore_service.dart';

class MockServerScreen extends StatefulWidget {
  @override
  _MockServerScreenState createState() => _MockServerScreenState();
}

class _MockServerScreenState extends State<MockServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<RequestConfig> requestConfigs = [];
  final List<TextEditingController> responseBodyControllers = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _addNewRequestConfig();
  }

  void _addNewRequestConfig() {
    setState(() {
      requestConfigs.add(RequestConfig());
      responseBodyControllers.add(TextEditingController());
    });
  }

  void _removeRequestConfig(int index) {
    setState(() {
      requestConfigs.removeAt(index);
      responseBodyControllers.removeAt(index);
    });
  }

  void _sendGetRequest(int index, String url) async {
    if (url.isNotEmpty) {
      var response = await _firestoreService.getRequest(url);
      if (response.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.errorMessage}')));
      } else {
        String formattedJson = JsonEncoder.withIndent('  ').convert(response.body);
        setState(() {
          responseBodyControllers[index].text = formattedJson;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Mock Server'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Select collection to mock', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: Text('Create a new collection'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: Text('Select an existing collection'),
              ),
              SizedBox(height: 16),
              Text('Enter the requests you want to mock. Optionally, add a request body by clicking on the (...) icon.'),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: requestConfigs.length,
                itemBuilder: (context, index) {
                  return RequestConfigWidget(
                    key: UniqueKey(),
                    config: requestConfigs[index],
                    responseBodyController: responseBodyControllers[index],
                    onRemove: () => _removeRequestConfig(index),
                  );
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addNewRequestConfig,
                child: Text('Add Request Configuration'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    for (var i = 0; i < requestConfigs.length; i++) {
                      var config = requestConfigs[i];
                      if (config.method == 'GET') {
                        _sendGetRequest(i, config.url);
                      } else {
                        Request request = Request(
                          method: config.method,
                          endpoint: config.url,
                          queryParams: config.queryParams,
                          body: config.responseBody,
                          environment: config.environment,
                        );
                        _firestoreService.createRequest(request).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request created successfully')));
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create request: $error')));
                        });
                      }
                    }
                  }
                },
                child: Text('Submit Requests'),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestConfig {
  String method;
  String url;
  int responseCode;
  String responseBody;
  Map<String, dynamic>? queryParams;
  String? environment;

  RequestConfig({
    this.method = 'POST',
    this.url = '',
    this.responseCode = 200,
    this.responseBody = '',
    this.queryParams,
    this.environment,
  });
}

class RequestConfigWidget extends StatelessWidget {
  final RequestConfig config;
  final VoidCallback onRemove;
  final TextEditingController responseBodyController;

  RequestConfigWidget({Key? key, required this.config, required this.onRemove, required this.responseBodyController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: config.method,
                    items: ['POST', 'GET', 'PUT', 'DELETE']
                        .map((method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    ))
                        .toList(),
                    onChanged: (value) {
                      config.method = value!;
                      (context as Element).markNeedsBuild();
                    },
                    decoration: InputDecoration(labelText: 'Request Method'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: config.url,
                    onChanged: (value) {
                      config.url = value;
                    },
                    decoration: InputDecoration(labelText: 'Request URL'),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: onRemove,
                ),
              ],
            ),
            if (config.method != 'GET')
              Column(
                children: [
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: config.responseCode.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      config.responseCode = int.parse(value);
                    },
                    decoration: InputDecoration(labelText: 'Response Code'),
                  ),
                ],
              ),
            SizedBox(height: 8),
            TextFormField(
              controller: responseBodyController,
              maxLines: null,
              onChanged: (value) {
                config.responseBody = value;
              },
              decoration: InputDecoration(labelText: 'Response Body'),
            ),
          ],
        ),
      ),
    );
  }
}
