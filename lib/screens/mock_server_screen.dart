import 'dart:convert';

import 'package:flutter/material.dart';
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

  void _sendGetRequest(int index, String path) async {
    if (path.isNotEmpty) {
      try {
        // Split the path to get collection and optional document ID
        var pathSegments = path.split('/');
        if (pathSegments.length % 2 == 0) {
          // Assume the last segment is a document ID
          var docId = pathSegments.removeLast();
          var collectionPath = pathSegments.join('/');
          var document = await _firestoreService.getDocument(collectionPath, docId);
          if (document != null) {
            String formattedJson = const JsonEncoder.withIndent('  ').convert(document);
            setState(() {
              responseBodyControllers[index].text = formattedJson;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document does not exist')));
          }
        } else {
          // Fetch all documents in the collection
          var collection = await _firestoreService.getCollection(path);
          String formattedJson = const JsonEncoder.withIndent('  ').convert(collection);
          setState(() {
            responseBodyControllers[index].text = formattedJson;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Mock Server'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Select collection to mock', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Create a new collection'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Select an existing collection'),
              ),
              const SizedBox(height: 16),
              const Text('TODO'),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addNewRequestConfig,
                child: const Text('Add Request Configuration'),
              ),
              const SizedBox(height: 16),
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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request created successfully')));
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create request: $error')));
                        });
                      }
                    }
                  }
                },
                child: const Text('Submit Requests'),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
               /* children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Next'),
                  ),
                ],*/
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

  const RequestConfigWidget({super.key, required this.config, required this.onRemove, required this.responseBodyController});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                    decoration: const InputDecoration(labelText: 'Request Method'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: config.url,
                    onChanged: (value) {
                      config.url = value;
                    },
                    decoration: const InputDecoration(labelText: 'Request URL'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: onRemove,
                ),
              ],
            ),
            if (config.method != 'GET')
              Column(
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: config.responseCode.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      config.responseCode = int.parse(value);
                    },
                    decoration: const InputDecoration(labelText: 'Response Code'),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            TextFormField(
              controller: responseBodyController,
              maxLines: null,
              onChanged: (value) {
                config.responseBody = value;
              },
              decoration: const InputDecoration(labelText: 'Response Body'),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}