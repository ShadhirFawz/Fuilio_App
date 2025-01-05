import 'package:flutter/material.dart';

class TextFieldInputs extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;

  const TextFieldInputs({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.icon,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TextFieldInputsState createState() => _TextFieldInputsState();
}

class _TextFieldInputsState extends State<TextFieldInputs> {
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        obscureText: widget.isPass ? _isPasswordHidden : false,
        controller: widget.textEditingController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: Colors.black45,
          ),
          suffixIcon: widget.isPass
              ? IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 15,
          ),
          filled: true,
          fillColor: const Color(0xFFedf0f8),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Colors.black,
            ), // Black border
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Colors.black,
            ), // Black border
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
