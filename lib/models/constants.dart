abstract class Constants {
  static const apiKey =
      String.fromEnvironment('GOOGLE_MAPS_API', defaultValue: '');
}
