import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import '../widgets/request_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

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
  List<RequestModel> savedRequests = [];
  RequestModel? selectedRequest;
  TextEditingController selectedResponseBodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSavedRequests();
    _addNewRequest();
  }

  void _fetchSavedRequests() async {
    String mockServerId = 'mockServerUUID'; // Use the actual mockServerId
    List<RequestModel> requests = await _firestoreService.getRequests(mockServerId);
    setState(() {
      savedRequests = requests;
    });
  }

  void _addNewRequest() {
    setState(() {
      RequestModel newRequest = RequestModel(
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
        headers: {},
        queryParams: {},
      );
      requests.add(newRequest);
      responseBodyControllers.add(TextEditingController());
      selectedRequest = newRequest; // Set the newly added request as selected
    });
  }

  void _removeRequest(int index) {
    setState(() {
      requests.removeAt(index);
      responseBodyControllers.removeAt(index);
      if (requests.isEmpty) {
        selectedRequest = null;
      } else {
        selectedRequest = requests.first;
      }
    });
  }

  Future<void> _logRequest(String mockServerId, RequestModel request) async {
    if (request.response == null) {
      request.response = {'responseStatusCode': 200, 'body': ''};
    }
    if (!request.response.containsKey('body')) {
      request.response['body'] = '';
    }
    await _firestoreService.createRequest(mockServerId, request);
  }

  Future<void> _sendGetRequest(String path) async {
    if (path.isNotEmpty) {
      try {
        print("Received request for path: $path");
        Uri uri = Uri.parse(path);
        List<String> segments = uri.pathSegments;

        if (selectedRequest == null) {
          print("Error: selectedRequest is null");
          return;
        }

        RequestModel request = selectedRequest!;
        request.uid = _uuid.v4();
        request.url = path;
        request.method = 'GET';
        request.createdAt = Timestamp.now();
        request.updatedAt = Timestamp.now();

        // Ensure the response map is initialized
        if (request.response == null) {
          request.response = {'responseStatusCode': 200, 'body': ''};
        }

        if (uri.host.isNotEmpty && uri.host != 'localhost') {
          // If the URL is an external API
          var response = await http.get(uri);
          setState(() {
            request.response['responseStatusCode'] = response.statusCode;
            request.response['body'] = response.body;
            selectedResponseBodyController.text = response.body;
          });
        } else {
          // Check if the request already exists in saved requests
          RequestModel? existingRequest = savedRequests.firstWhereOrNull(
                (savedRequest) => savedRequest.url == path,
          );

          print("Existing request: $existingRequest");

          if (existingRequest != null) {
            // Use the existing request's response
            setState(() {
              print("Using existing request response");
              selectedResponseBodyController.text = existingRequest.response['body'];
              request.response['responseStatusCode'] = existingRequest.response['responseStatusCode'];
              request.response['body'] = existingRequest.body;
            });
          } else {
            if (segments.length >= 2 && segments[0] == 'mockServers') {
              String mockServerId = segments[1];

              // If the URL has three segments, we treat the last segment as the collection name
              if (segments.length == 3) {
                String collectionName = segments[2];
                var collectionData = await _firestoreService.getCollection('mockServers/$mockServerId/$collectionName');
                print("Collection data: $collectionData");
                if (collectionData.isNotEmpty) {
                  setState(() {
                    selectedResponseBodyController.text = jsonEncode(collectionData);
                    request.response['responseStatusCode'] = 200;
                    request.response['body'] = jsonEncode(collectionData);
                  });
                } else {
                  setState(() {
                    selectedResponseBodyController.text = '404 Not Found';
                    request.response['responseStatusCode'] = 404;
                  });
                }
              } else if (segments.length == 4) {
                String collectionName = segments[2];
                String docId = segments[3];
                var document = await _firestoreService.getDocument('mockServers/$mockServerId/$collectionName', docId);
                print("Document data: $document");
                if (document != null) {
                  setState(() {
                    selectedResponseBodyController.text = jsonEncode(document);
                    request.response['responseStatusCode'] = 200;
                    request.response['body'] = jsonEncode(document);
                  });
                } else {
                  setState(() {
                    selectedResponseBodyController.text = '404 Not Found';
                    request.response['responseStatusCode'] = 404;
                  });
                }
              } else {
                print("Invalid URL structure");
                setState(() {
                  selectedResponseBodyController.text = '404 Not Found';
                  request.response['responseStatusCode'] = 404;
                });
              }

              await _logRequest(mockServerId, request);
              _fetchSavedRequests(); // Refresh the saved requests
            } else {
              print("Invalid URL structure");
              setState(() {
                selectedResponseBodyController.text = '404 Not Found';
                request.response['responseStatusCode'] = 404;
              });
            }
          }
        }
        print("Response body after request: ${selectedResponseBodyController.text}");
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

  void _selectRequest(RequestModel request) {
    setState(() {
      selectedRequest = request;
      selectedResponseBodyController.clear(); // Clear the response body when selecting a request
      print("Selected request: ${request.requestName}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mock Server'),
      ),
      body: Row(
        children: [
          // Sidebar for saved requests
          Container(
            width: 250,
            child: ListView.builder(
              itemCount: savedRequests.length,
              itemBuilder: (context, index) {
                RequestModel request = savedRequests[index];
                return ListTile(
                  title: Text('[${request.method}] ${request.requestName}'),
                  onTap: () => _selectRequest(request),
                );
              },
            ),
          ),
          // Main content area for request details
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter the requests you want to mock. Optionally, add a request body by clicking on the (...) icon.'),
                    SizedBox(height: 16),
                    if (selectedRequest != null) ...[
                      RequestWidget(
                        key: UniqueKey(),
                        request: selectedRequest!,
                        responseBodyController: selectedResponseBodyController,
                        onRemove: () {},
                        onDelete: () => _sendDeleteRequest(0, selectedRequest!.url),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _sendGetRequest(selectedRequest!.url);
                          }
                        },
                        child: Text('Submit Request'),
                      ),
                    ] else ...[
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
                                _sendGetRequest(request.url);
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
                    ],
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
          ),
        ],
      ),
    );
  }
}
