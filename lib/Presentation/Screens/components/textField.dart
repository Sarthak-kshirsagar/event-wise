import 'package:flutter/material.dart';

Widget event_wise_text_field({
  required TextEditingController textEditingController,
  required BuildContext context,
  required String hintText,
  required IconData icon,
  String? Function(String?)? validator,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  TextInputAction textInputAction = TextInputAction.next,
}) {
  return Container(
    width: MediaQuery.of(context).size.width - 50,
    child: TextFormField(
      controller: textEditingController,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        hintText: hintText,
      ),
    ),
  );
}
