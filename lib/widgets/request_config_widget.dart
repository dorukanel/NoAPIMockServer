import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/request.dart';

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