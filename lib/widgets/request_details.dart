import 'package:flutter/material.dart';
import '../models/request_model.dart';
import 'request_widget.dart';

class RequestDetails extends StatefulWidget {
  final RequestModel request;
  final TextEditingController responseBodyController;
  final VoidCallback onDelete;
  final Function(String, String) onSend;

  const RequestDetails({
    Key? key,
    required this.request,
    required this.responseBodyController,
    required this.onDelete,
    required this.onSend,
  }) : super(key: key);

  @override
  _RequestDetailsState createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RequestWidget(
            key: UniqueKey(),
            request: widget.request,
            responseBodyController: widget.responseBodyController,
            onRemove: () {},
            onDelete: widget.onDelete,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.onSend(widget.request.method, widget.request.url);
              }
            },
            child: Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
