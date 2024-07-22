import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/request.dart';
import '../services/firestore_service.dart';
import '../widgets/request_widget.dart';

class MockServerScreen extends StatefulWidget {
  @override
  _MockServerScreenState createState() => _MockServerScreenState();
}

class _MockServerScreenState extends State<MockServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Request> requests = [];
  final List<TextEditingController> responseBodyControllers = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _addNewRequest();
  }

  void _addNewRequest() {
    setState(() {
      requests.add(Request(method: 'POST', endpoint: '',responseCode: null));
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
        var pathSegments = path.split('/');
        if (pathSegments.length % 2 == 0) {
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

  void _sendPostRequest(int index, String path, String requestBody) async {
    if (path.isNotEmpty) {
      try {
        print('Request Body: $requestBody');
        var data = json.decode(requestBody);
        print('Decoded Data: $data');
        print('Data Type: ${data.runtimeType}');
        if (data is Map<String, dynamic>) {
          await _firestoreService.createDocument(path, data);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document created successfully')));
        } else if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              await _firestoreService.createDocument(path, item);
            } else {
              throw TypeError();
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Documents created successfully')));
        } else {
          print('TypeError: Data is not a Map<String, dynamic> or List<Map<String, dynamic>>');
          throw TypeError();
        }
      } catch (e) {
        String errorMessage = 'An error occurred';
        if (e is FormatException) {
          errorMessage = 'Invalid JSON format: ${e.message}';
        } else if (e is TypeError) {
          errorMessage = 'Invalid data type: Request body must be a JSON object or an array of JSON objects';
        } else {
          errorMessage = 'Error: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
  void _sendDeleteRequest(int index, String path) async {
    if (path.isNotEmpty) {
      try {
        var pathSegments = path.split('/');
        if (pathSegments.length % 2 == 0) {
          var docId = pathSegments.removeLast();
          var collectionPath = pathSegments.join('/');
          await _firestoreService.deleteDocument(collectionPath, docId);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document deleted successfully')));
        } else {
          await _firestoreService.deleteCollection(path);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Collection deleted successfully')));
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
                      }
                      else if(request.method =='DELETE'){
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