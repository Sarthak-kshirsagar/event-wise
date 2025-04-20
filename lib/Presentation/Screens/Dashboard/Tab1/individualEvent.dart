import 'package:flutter/material.dart';
import '../../../styles/elevated_button_style.dart';
import 'evet_register.dart';
class Individualevent extends StatefulWidget {
  String name = '';
  String date = '';
  String organizer = '';
  String eventInfo = '';
  String startTime = '';
  String endTime = '';
  String venue = '';
  String description = '';
  int min_team_size = 0;
  int max_team_size = 0;
  String event_id = '';
  String organizer_id = '';

   Individualevent({required this.organizer_id,required this.max_team_size,required this.min_team_size, required this.event_id,required this.description,required this.venue,required this.startTime, required this.endTime,required this.name,required this.date, required this.organizer, required this.eventInfo});

  @override
  State<Individualevent> createState() => _IndividualeventState();
}

class _IndividualeventState extends State<Individualevent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: MediaQuery.of(context).size.width,child: Image.asset(fit: BoxFit.cover,"assets/images/event1.png")),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${widget.name}",style: TextStyle(
                fontSize: 20
              ),),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.location_on,size: 30,),
                  ),

                ),
                SizedBox(width: 10,),
                Column(
                  children: [
                    Text("${widget.venue}"),
                    SizedBox(height: 5,),
                    Text("Sector 26, Nigidi")
                  ],
                )
              ],
            ),
            SizedBox(height: 25,),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.calendar_month,size: 30,),
                  ),

                ),
                SizedBox(width: 10,),
                Column(
                  children: [
                    Text("${widget.date}"),
                    SizedBox(height: 5,),
                    Text("${widget.startTime} - ${widget.endTime}")
                  ],
                )
              ],
            ),

            SizedBox(height: 25,),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.event,size: 30,),
                  ),

                ),
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${widget.organizer}"),
                    SizedBox(height: 5,),
                    Text("Organizer")
                  ],
                )
              ],
            ),
            SizedBox(height: 25,),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.share,size: 30,),
                  ),

                ),
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Let your Friends know about this event"),
                    SizedBox(height: 5,),
                    Text("Share")
                  ],
                )
              ],
            ),
            SizedBox(height: 25,),

            ExpansionTile(title: Text("Event Info",),children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                 "${widget.description}",
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],),
            SizedBox(height: 15,),
            Center(child: Container(height: 50,child: ElevatedButton(style: elevated_button_style(),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => EligibleTeamsScreen(organizer_id: widget.organizer_id,minTeamSize: 1,eventId:widget.event_id,maxTeamSize: 3,),));
            }, child: Text("Register for Event")))),
            SizedBox(height: 15,),
          ],
        ),
      )),
    );
  }
}
