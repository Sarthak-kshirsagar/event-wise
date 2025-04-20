import 'package:flutter/material.dart';

Widget recommended_events({required ctx,required image,required event_name,required startdate,required enddate,required Widget w}){
  return  Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    width: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          // spreadRadius: 1,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16), // Apply to image too
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150, // Fixed height for image
            width: double.infinity,
            child: Image.asset(
              "${image}",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${event_name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "${startdate} - ${enddate}",
              style: TextStyle(
                color: Colors.purple.shade200,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
               Navigator.push(ctx, MaterialPageRoute(builder: (context) => w,));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "View More",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}