import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import '../services/request_service.dart';
import '../widgets/request_list.dart';
import '../widgets/request_details.dart';

class MockServerScreen extends StatefulWidget {
  @override
  _MockServerScreenState createState() => _MockServerScreenState();
}

class _MockServerScreenState extends State<MockServerScreen> {
  final List<RequestModel> requests = [];
  final List<TextEditingController> responseBodyControllers = [];
  final FirestoreService _firestoreService = FirestoreService();
  final RequestService _requestService = RequestService();
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
    List<RequestModel> savedRequests = await _firestoreService.getRequests(mockServerId);
    setState(() {
      requests.addAll(savedRequests);
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
      selectedRequest = newRequest;
    });
  }

  void _selectRequest(RequestModel request) {
    setState(() {
      selectedRequest = request;
      selectedResponseBodyController.clear();
    });
  }

  void _sendRequestHandler(String method, String url) {
    if (selectedRequest != null) {
      _requestService.sendRequest(
        method,
        url,
        selectedRequest!,
        requestBody: selectedRequest!.body,
        selectedResponseBodyController: selectedResponseBodyController,
        refreshSavedRequests: _fetchSavedRequests,
        context: context,
      );
    }
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
            child: RequestList(
              requests: requests,
              onSelect: _selectRequest,
            ),
          ),
          // Main content area for request details
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: selectedRequest != null
                  ? RequestDetails(
                request: selectedRequest!,
                responseBodyController: selectedResponseBodyController,
                onDelete: () => _removeRequest(requests.indexOf(selectedRequest!)),
                onSend: _sendRequestHandler,
              )
                  : Center(
                child: Text('Select a request to view details'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
