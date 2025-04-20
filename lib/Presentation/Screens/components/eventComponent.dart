import 'package:flutter/material.dart';

Widget event_component({
  required BuildContext context,
  required String eventName,
  required String eventImage,
}) {
  return Container(
    height: 100,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            eventImage,
            height: 70,
            width: 70,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            eventName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Colors.grey,
        )
      ],
    ),
  );
}
