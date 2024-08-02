import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'firestore_service.dart';

void main() async {
  final FirestoreService firestoreService = FirestoreService();
  final router = Router();

  // Handle GET requests dynamically for different collections
  router.get('/mockServers/<mockServerId>/<collectionName>', (Request request, String mockServerId, String collectionName) async {
    try {
      // Path to the specific collection within the mockServer
      var collectionPath = 'mockServers/$mockServerId/requests';

      var collectionData = await firestoreService.getCollection(collectionPath, request.url.queryParameters);
      print("Collection data: $collectionData");

      if (collectionData.isNotEmpty) {
        var responseBodies = collectionData.map((data) {
          // Parse each 'body' from the collection data
          return jsonDecode(data['body']);
        }).toList();

        return Response.ok(jsonEncode(responseBodies), headers: {'Content-Type': 'application/json'});
      } else {
        return Response.notFound('No data found');
      }
    } catch (e) {
      print('Error: $e');
      return Response.internalServerError(body: 'Error: $e');
    }
  });

  // Create a Shelf handler that includes both the router and static file handler
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);

  // Start the server
  final server = await shelf_io.serve(handler, 'localhost', 3000);
  print('Server listening on port ${server.port}');
}
