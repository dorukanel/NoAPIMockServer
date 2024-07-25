import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/request.dart';
import '../services/firestore_service.dart';
import '../widgets/request_widget.dart';
import '../services/mock_data_service.dart';

class MockServerScreen extends StatefulWidget {
  @override
  _MockServerScreenState createState() => _MockServerScreenState();
}

class _MockServerScreenState extends State<MockServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Request> requests = [];
  final List<TextEditingController> responseBodyControllers = [];
  final FirestoreService _firestoreService = FirestoreService();
  final MockDataService _mockDataService = MockDataService();

  @override
  void initState() {
    super.initState();
    _addNewRequest();
  }

  void _addNewRequest() {
    setState(() {
      requests.add(Request(method: 'POST', endpoint: '', responseCode: null));
      responseBodyControllers.add(TextEditingController());
    });
  }

  void _removeRequest(int index) {
    setState(() {
      requests.removeAt(index);
      responseBodyControllers.removeAt(index);
    });
  }

  void _sendGetRequest(int index, String path) async {
    if (path.isNotEmpty) {
      try {
        // Parse the URL to extract the collection and document ID
        Uri uri = Uri.parse(path);
        List<String> segments = uri.pathSegments;

        if (segments.isNotEmpty) {
          String collection = segments[0];
          String? docId = segments.length > 1 ? segments[1] : null;

          if (docId != null) {
            var document = await _mockDataService.getDocument(collection, docId);
            setState(() {
              responseBodyControllers[index].text = jsonEncode(document);
            });
          } else {
            var collectionData = await _mockDataService.getCollection(collection);
            setState(() {
              responseBodyControllers[index].text = jsonEncode(collectionData);
            });
          }
        } else {
          throw Exception('Invalid URL structure');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _sendPostRequest(int index, String path, String requestBody) async {
    // Implement POST request logic if necessary
  }

  void _sendDeleteRequest(int index, String path) async {
    // Implement DELETE request logic if necessary
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
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return RequestWidget(
                    key: UniqueKey(),
                    request: requests[index],
                    responseBodyController: responseBodyControllers[index],
                    onRemove: () => _removeRequest(index),
                    onDelete: () => _sendDeleteRequest(index, requests[index].endpoint),
                  );
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addNewRequest,
                child: Text('Add Request Configuration'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    for (var i = 0; i < requests.length; i++) {
                      var request = requests[i];
                      if (request.method == 'GET') {
                        _sendGetRequest(i, request.endpoint);
                      } else if (request.method == 'POST') {
                        _sendPostRequest(i, request.endpoint, request.responseBody ?? '');
                      } else if (request.method == 'DELETE') {
                        _sendDeleteRequest(i, request.endpoint);
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
