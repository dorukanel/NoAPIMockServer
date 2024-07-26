import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mock_server_model.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import '../widgets/request_widget.dart';
import '../widgets/add_mock_data_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockServerScreen extends StatefulWidget {
  @override
  _MockServerScreenState createState() => _MockServerScreenState();
}

class _MockServerScreenState extends State<MockServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<RequestModel> requests = [];
  final List<TextEditingController> responseBodyControllers = [];
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _addNewRequest();
  }

  void _addNewRequest() {
    setState(() {
      requests.add(RequestModel(
        uid: '',
        requestName: '',
        url: '',
        method: 'GET',
        body: '',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        response: {
          'responseStatusCode': 200,
          'body': '',
        },
      ));
      responseBodyControllers.add(TextEditingController());
    });
  }

  void _removeRequest(int index) {
    setState(() {
      requests.removeAt(index);
      responseBodyControllers.removeAt(index);
    });
  }

  Future<void> _logRequest(String mockServerId, RequestModel request) async {
    await _firestoreService.createRequest(mockServerId, request);
  }

  void _sendGetRequest(int index, String path) async {
    if (path.isNotEmpty) {
      try {
        print("Received request for path: $path");
        Uri uri = Uri.parse(path);
        List<String> segments = uri.pathSegments;

        RequestModel request = requests[index];
        request.uid = _uuid.v4();
        request.url = path;
        request.method = 'GET';
        request.createdAt = Timestamp.now();
        request.updatedAt = Timestamp.now();

        if (segments.length >= 2 && segments[0] == 'mockServers') {
          String mockServerId = segments[1];

          // If the URL has three segments, we treat the last segment as the collection name
          if (segments.length == 3) {
            String collectionName = segments[2];
            var collectionData = await _firestoreService.getCollection('mockServers/$mockServerId/$collectionName');
            if (collectionData.isNotEmpty) {
              setState(() {
                responseBodyControllers[index].text = jsonEncode(collectionData);
                request.response['responseStatusCode'] = 200;
                request.response['body'] = jsonEncode(collectionData);
              });
            } else {
              setState(() {
                responseBodyControllers[index].text = '404 Not Found';
                request.response['responseStatusCode'] = 404;
              });
            }
          } else if (segments.length == 4) {
            String collectionName = segments[2];
            String docId = segments[3];
            var document = await _firestoreService.getDocument('mockServers/$mockServerId/$collectionName', docId);
            if (document != null) {
              setState(() {
                responseBodyControllers[index].text = jsonEncode(document);
                request.response['responseStatusCode'] = 200;
                request.response['body'] = jsonEncode(document);
              });
            } else {
              setState(() {
                responseBodyControllers[index].text = '404 Not Found';
                request.response['responseStatusCode'] = 404;
              });
            }
          } else {
            print("Invalid URL structure");
            setState(() {
              responseBodyControllers[index].text = '404 Not Found';
              request.response['responseStatusCode'] = 404;
            });
          }

          await _logRequest(mockServerId, request);
        } else {
          print("Invalid URL structure");
          setState(() {
            responseBodyControllers[index].text = '404 Not Found';
            request.response['responseStatusCode'] = 404;
          });
        }
      } catch (e) {
        print("Error: $e");
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

  void _openAddMockDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddMockDataDialog(firestoreService: _firestoreService);
      },
    );
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
                onPressed: _openAddMockDataDialog,
                child: Text('Add Mock Data'),
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
                    onDelete: () => _sendDeleteRequest(index, requests[index].url),
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
                        _sendGetRequest(i, request.url);
                      } else if (request.method == 'POST') {
                        _sendPostRequest(i, request.url, request.body);
                      } else if (request.method == 'DELETE') {
                        _sendDeleteRequest(i, request.url);
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
