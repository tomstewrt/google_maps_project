import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'helpers/location_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  final zoomLevel = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: LocationHelper.getCurrentLocation(),
          builder: (context, snapshot) {
            Widget body;
            if (snapshot.hasError) {
              body = _buildErrorText(snapshot.error.toString());
            } else if (snapshot.hasData) {
              final Position? currentLocation = snapshot.data;
              if (currentLocation != null) {
                body = _buildMap(currentLocation);
              } else {
                // IF there is an issue with the location show user error message
                body = _buildErrorText(
                    'There was an issue fetching your location.');
              }
            } else {
              body = const Center(child: CircularProgressIndicator());
            }
            return Scaffold(body: SafeArea(child: body));
          },
        ),
      ),
    );
  }

  Widget _buildMap(Position currentLocation) {
    final locationLatLng =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: locationLatLng,
            zoom: zoomLevel,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorText(String text) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(color: Theme.of(context).errorColor),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
