import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScannerScreen extends StatefulWidget {
  String event_id = '';
   QRScannerScreen({Key? key,required this.event_id}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 8,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
    );
  }
  String? _extractValue(String text, String key) {
    final regex = RegExp('$key\\s*[:-]+\\s*(\\S+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1);
  }

Future<void> mark_attendance({required user_id})async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    String userId = await _auth.currentUser!.uid;
    CollectionReference ref = FirebaseFirestore.instance.collection("Organizers");
    QuerySnapshot organizerSnap = await ref.where("id",isEqualTo: "${userId}").get();
    if(organizerSnap.docs.isNotEmpty){
      CollectionReference eventRef = await organizerSnap.docs.first.reference.collection('Events');
      QuerySnapshot eventSnap = await eventRef.where("id",isEqualTo: "${widget.event_id}").get();
      if(eventSnap.docs.isNotEmpty){
        CollectionReference attendanceRef  = await eventSnap.docs.first.reference.collection('Attendance');
        await attendanceRef.add({
          'user_id':'${user_id}',
          'date':'${DateTime.now().toString()}'
        });
      }
      
    }
}
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final scannedCode = scanData.code ?? '';
      log('QR Code Scanned: $scannedCode');
      controller.pauseCamera();

      // final eventId = _extractValue(scannedCode, 'EventId');
      // final organizerId = _extractValue(scannedCode, 'OrganizerId');
      //
      // log('Parsed Event ID: $eventId');
      // log('Parsed Organizer ID: $organizerId');

      // if (eventId != null && organizerId != null) {
      //   yourFunction(eventId, organizerId);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Invalid QR Code format')),
      //   );
      // }
      print("Here is the user id ${scannedCode} and ${widget.event_id}");

      mark_attendance(user_id: scannedCode.trim());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Attendance Marked")));

      Navigator.pop(context);
    });
  }


  void yourFunction(String eventId, String organizerId) {
    // Example: Fetch event from Firestore or verify registration
    // log("Calling your function with EventID: $eventId and OrganizerID: $organizerId");
    print("Event id is ${eventId}");

  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('Permission set: $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission not granted')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
