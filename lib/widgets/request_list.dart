import 'package:flutter/material.dart';
import '../models/request_model.dart';

class RequestList extends StatelessWidget {
  final List<RequestModel> requests;
  final Function(RequestModel) onSelect;

  const RequestList({
    Key? key,
    required this.requests,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        RequestModel request = requests[index];
        return ListTile(
          title: Text('[${request.method}] ${request.requestName}'),
          onTap: () => onSelect(request),
        );
      },
    );
  }
}
