import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';

class AddMockDataDialog extends StatefulWidget {
  final FirestoreService firestoreService;

  const AddMockDataDialog({Key? key, required this.firestoreService}) : super(key: key);

  @override
  _AddMockDataDialogState createState() => _AddMockDataDialogState();
}

class _AddMockDataDialogState extends State<AddMockDataDialog> {
  final _workspaceIdController = TextEditingController();
  final _mockDataNameController = TextEditingController();
  final _jsonController = TextEditingController();
  final Uuid _uuid = Uuid();

  void _addMockData() async {
    String workspaceId = _workspaceIdController.text;
    String mockDataName = _mockDataNameController.text;
    String jsonData = _jsonController.text;

    if (workspaceId.isNotEmpty && mockDataName.isNotEmpty && jsonData.isNotEmpty) {
      try {
        List<dynamic> data = json.decode(jsonData);
        List<Map<String, dynamic>> mockData = List<Map<String, dynamic>>.from(data);

        await widget.firestoreService.addMockData(workspaceId, mockDataName, mockData);

        // Adding a request to the 'requests' collection
        RequestModel request = RequestModel(
          uid: _uuid.v4(),
          requestName: mockDataName,
          url: '$mockDataName/',
          method: 'GET',
          body: '',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          response: {
            'responseStatusCode': 200,
            'body': jsonEncode(mockData),
          },
        );
        await widget.firestoreService.createRequest(workspaceId, request);

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String fileContent = await File(filePath).readAsString();
      _jsonController.text = fileContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Mock Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _workspaceIdController,
              decoration: InputDecoration(labelText: 'Workspace ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _mockDataNameController,
              decoration: InputDecoration(labelText: 'Mock Data Name'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _jsonController,
              maxLines: 10,
              decoration: InputDecoration(labelText: 'Mock Data (JSON)'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Upload File'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addMockData,
          child: Text('Add Mock Data'),
        ),
      ],
    );
  }
}
