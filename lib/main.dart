import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
                body = _buildMap();
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

  Widget _buildMap() {
    return SizedBox();
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
}
