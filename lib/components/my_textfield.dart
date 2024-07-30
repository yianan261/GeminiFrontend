import 'package:flutter/material.dart';

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
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: _handleAdd,
          ),
        ),
        onSubmitted: (value) {
          _handleAdd();
        },
      ),
    );
  }
}
