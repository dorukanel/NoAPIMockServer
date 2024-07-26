import 'package:flutter/material.dart';
import '../models/request_model.dart';

class RequestWidget extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onRemove;
  final TextEditingController responseBodyController;
  final VoidCallback onDelete;

  const RequestWidget({
    super.key,
    required this.request,
    required this.onRemove,
    required this.responseBodyController,
    required this.onDelete,
  });

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
                    value: request.method,
                    items: ['POST', 'GET', 'PUT', 'DELETE']
                        .map((method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    ))
                        .toList(),
                    onChanged: (value) {
                      request.method = value!;
                      (context as Element).markNeedsBuild();
                    },
                    decoration: const InputDecoration(labelText: 'Request Method'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: request.url,
                    onChanged: (value) {
                      request.url = value;
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (request.method != 'GET' && request.method != 'DELETE')
                  Expanded(
                    child: TextFormField(
                      initialValue: request.response['responseStatusCode']?.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        request.response['responseStatusCode'] = int.parse(value);
                      },
                      decoration: const InputDecoration(labelText: 'Response Code'),
                    ),
                  ),
                if (request.method == 'GET' || request.method == 'DELETE')
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: request.response['responseStatusCode'] == 200 ? Colors.green : Colors.red,
                    ),
                    child: Text('${request.response['responseStatusCode']}'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (request.method != 'DELETE')
              TextFormField(
                controller: responseBodyController,
                maxLines: null,
                onChanged: (value) {
                  request.response['body'] = value;
                },
                decoration: const InputDecoration(labelText: 'Response Body'),
                style: const TextStyle(fontSize: 12),
              ),
            if (request.method == 'DELETE')
              ElevatedButton(
                onPressed: onDelete,
                child: const Text('Delete Document'),
              )
          ],
        ),
      ),
    );
  }
}
