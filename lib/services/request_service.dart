import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import 'firestore_service.dart';

class RequestService {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = Uuid();

  Future<void> sendRequest(String method, String path, RequestModel request, {String requestBody = '', required TextEditingController selectedResponseBodyController, required Function() refreshSavedRequests, required BuildContext context}) async {
    if (path.isNotEmpty) {
      try {
        print("Received $method request for path: $path with body: $requestBody");
        Uri uri = Uri.parse(path);

        request.uid = _uuid.v4();
        request.url = path;
        request.method = method;
        request.body = requestBody;
        request.createdAt = Timestamp.now();
        request.updatedAt = Timestamp.now();

        // Ensure the response map is initialized
        if (request.response == null) {
          request.response = {'responseStatusCode': 200, 'body': ''};
        }

        if (uri.host.isNotEmpty && uri.host != 'localhost') {
          // If the URL is an external API
          http.Response response;
          switch (method) {
            case 'POST':
              response = await http.post(uri, body: requestBody);
              break;
            case 'PUT':
              response = await http.put(uri, body: requestBody);
              break;
            case 'DELETE':
              response = await http.delete(uri);
              break;
            case 'GET':
            default:
              response = await http.get(uri);
              break;
          }

          selectedResponseBodyController.text = response.body;
          request.response['responseStatusCode'] = response.statusCode;
          request.response['body'] = response.body;
        } else {
          // Handle request logic for local paths
          List<String> segments = uri.pathSegments;
          RequestModel? existingRequest = await _firestoreService.getRequestByUrlAndMethod(segments[1], path, method);

          if (existingRequest != null) {
            selectedResponseBodyController.text = existingRequest.response['body'];
            request.response['responseStatusCode'] = existingRequest.response['responseStatusCode'];
            request.response['body'] = existingRequest.body;
          } else {
            if (segments.length >= 2 && segments[0] == 'mockServers') {
              String mockServerId = segments[1];

              if (method == 'GET') {
                if (segments.length == 3) {
                  String collectionName = segments[2];
                  var collectionData = await _firestoreService.getCollection('mockServers/$mockServerId/$collectionName', request.queryParams);
                  if (collectionData.isNotEmpty) {
                    selectedResponseBodyController.text = jsonEncode(collectionData);
                    request.response['responseStatusCode'] = 200;
                    request.response['body'] = jsonEncode(collectionData);
                  } else {
                    selectedResponseBodyController.text = '404 Not Found';
                    request.response['responseStatusCode'] = 404;
                  }
                } else if (segments.length == 4) {
                  String collectionName = segments[2];
                  String docId = segments[3];
                  var document = await _firestoreService.getDocument('mockServers/$mockServerId/$collectionName', docId);
                  if (document != null) {
                    selectedResponseBodyController.text = jsonEncode(document);
                    request.response['responseStatusCode'] = 200;
                    request.response['body'] = jsonEncode(document);
                  } else {
                    selectedResponseBodyController.text = '404 Not Found';
                    request.response['responseStatusCode'] = 404;
                  }
                } else {
                  selectedResponseBodyController.text = '404 Not Found';
                  request.response['responseStatusCode'] = 404;
                }
              } else if (method == 'POST' || method == 'PUT') {
                selectedResponseBodyController.text = requestBody;
                request.response['responseStatusCode'] = 200;
                request.response['body'] = 'Request processed';
              } else if (method == 'DELETE') {
                selectedResponseBodyController.text = 'Request not found';
                request.response['responseStatusCode'] = 404;
                request.response['body'] = 'Request not found';
              }

              await _firestoreService.createRequest(mockServerId, request);
              refreshSavedRequests(); // Refresh the saved requests
            } else {
              selectedResponseBodyController.text = '404 Not Found';
              request.response['responseStatusCode'] = 404;
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
}
