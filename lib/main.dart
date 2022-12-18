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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(5),
            elevation: 10,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
  final btnBlue = const Color(0xFF2EC1EF);
  final btnPurple = const Color(0xFF9A2EEF);
  late BitmapDescriptor locationIcon;

  @override
  void initState() {
    // Set the location icon from the asset image
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(40, 40)),
            'images/location-icon.png')
        .then((value) => locationIcon = value);
    super.initState();
  }

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
              final LatLng? currentLocation = snapshot.data;
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

  Future<void> _moveCameraToPosition(LatLng latLng) async {
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: zoomLevel),
      ),
    );
  }

  // Build the map and the overlay
  Widget _buildMap(LatLng currentLocation) {
    return Stack(
      children: [
        GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: zoomLevel,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('location'),
                anchor: const Offset(0.5, 0.5),
                icon: locationIcon,
                position: currentLocation,
              ),
            }),
        // Buttons container
        _buildBottomButtons(),
      ],
    );
  }

  // Build the two bottom buttons and their container
  Widget _buildBottomButtons() {
    final size = MediaQuery.of(context).size;
    final btnWidth = size.width * 0.6;
    const btnHeight = 70.0;
    final btnSize = Size(btnWidth, btnHeight);
    return Container(
      margin: const EdgeInsets.all(10),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBlue,
              fixedSize: btnSize,
            ),
            onPressed: () {
              _moveCameraToPosition(LocationHelper.getRandomPosition());
            },
            child: const Text(
              'Teleport me to somewhere random',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnPurple,
              fixedSize: btnSize,
            ),
            onPressed: () {
              LocationHelper.getCurrentLocation().then((location) {
                _moveCameraToPosition(location);
              });
            },
            child: const Text(
              'Bring me back home',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
