import 'package:flutter/material.dart';

Widget my_events_card({required context,required eventName,required eventTime,required imagePath}){
  return Material(
    elevation: 2,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width-10,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.white,spreadRadius: 10,blurRadius: 10)
            ]
        ),
        height: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 150,
                  height: 130,
                  decoration: BoxDecoration(
                      color: Colors.white
                  ),
                  child: ClipRRect(
                    child: Image.asset("${imagePath}"),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(width: 15,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${eventTime}"),
                    SizedBox(height: 15,),
                    Text("${eventName}",style: TextStyle(
                        fontWeight: FontWeight.bold,fontSize: 18
                    ),)
                  ],
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
}