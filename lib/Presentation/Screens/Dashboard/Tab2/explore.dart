// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
//
// /// A simple event model.
// class Event {
//   final String title;
//   final LatLng location;
//
//   Event({required this.title, required this.location});
// }
//
// class MapScreen extends StatelessWidget {
//   MapScreen({Key? key}) : super(key: key);
//
//   // Sample events.
//   final List<Event> events = [
//     Event(title: "Event 1", location: LatLng(37.7749, -122.4194)), // San Francisco
//     Event(title: "Event 2", location: LatLng(34.0522, -118.2437)), // Los Angeles
//     Event(title: "Event 3", location: LatLng(40.7128, -74.0060)),  // New York
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     // Center the map on the first event or fallback to (0,0).
//     final LatLng initialCenter = events.isNotEmpty ? events[0].location : LatLng(0, 0);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Events Map"),
//       ),
//       body: FlutterMap(
//         options: MapOptions(
//           center: initialCenter,
//           zoom: 5.0,
//         ),
//         // In flutter_map 4.0.0, use the 'layers' parameter with a list of LayerOptions.
//         layers: <LayerOptions>[
//           TileLayerOptions(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//             // Provide attribution using attributionBuilder.
//             attributionBuilder: (_) {
//               return const Text("© OpenStreetMap contributors");
//             },
//           ),
//           MarkerLayerOptions(
//             markers: events.map((event) {
//               return Marker(
//                 width: 80.0,
//                 height: 80.0,
//                 point: event.location,
//                 builder: (ctx) => Tooltip(
//                   message: event.title,
//                   child: const Icon(
//                     Icons.location_on,
//                     color: Colors.red,
//                     size: 40.0,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
