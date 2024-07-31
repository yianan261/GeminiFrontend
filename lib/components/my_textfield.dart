import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddableTextField extends StatefulWidget {
  final Function(String) onAdd;
  final String hintText;

  const AddableTextField({
    Key? key,
    required this.onAdd,
    required this.hintText,
  }) : super(key: key);

  @override
  _AddableTextFieldState createState() => _AddableTextFieldState();
}

class _AddableTextFieldState extends State<AddableTextField> {
  final TextEditingController _controller = TextEditingController();

  void _handleAdd() {
    widget.onAdd(_controller.text);
    _controller.clear(); // Clear the text field to show the hint text again
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 20, // Set a minimum height for the text field
        ),
        child: TextField(
          controller: _controller,
          maxLines: null, // Allow the text field to expand vertically
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintMaxLines: 3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            suffixIcon: IconButton(
              icon: Icon(CupertinoIcons.paperplane_fill, color: Colors.black),
              onPressed: _handleAdd,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Adjust padding
          ),
          onSubmitted: (value) {
            _handleAdd();
          },
        ),
      ),
    );
  }
}
