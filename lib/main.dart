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
  List<LatLng> previousLocations = [];

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
          },
        ),
        Positioned(
          right: 10,
          top: 10,
          child: SizedBox(
            height: 48,
            width: 48,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => _buildModal(currentLocation),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
        ),
        // Buttons container
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildModal(LatLng currentLocation) {
    final size = MediaQuery.of(context).size;
    const textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    const spacer = SizedBox(height: 20);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(left: 0, right: 0),
        child: Stack(
          children: [
            Container(
              width: size.width * 0.7,
              padding: const EdgeInsets.only(top: 10),
              margin: const EdgeInsets.only(top: 20, right: 20),
              color: const Color.fromARGB(211, 196, 196, 196),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Current Location', style: textStyle),
                    spacer,
                    Text(
                      'Latitude: ${currentLocation.latitude.toStringAsFixed(2)}',
                      style: textStyle,
                    ),
                    Text(
                      'Longitude: ${currentLocation.longitude.toStringAsFixed(2)}',
                      style: textStyle,
                    ),
                    spacer,
                    const Text('Previous', style: textStyle),
                    const SizedBox(height: 15),
                    ...previousLocations.map(
                      (location) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Lat: ${location.latitude.toStringAsFixed(2)}, Long: ${location.longitude.toStringAsFixed(2)}',
                          style: textStyle,
                        ),
                      ),
                    ),
                    spacer,
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 55, 41, 41),
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
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
              // Get the random position and store it in the previous locations
              final randomPosition = LocationHelper.getRandomPosition();
              setState(() => previousLocations.add(randomPosition));
              _moveCameraToPosition(randomPosition);
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
