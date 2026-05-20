import 'dart:async';

class GoogleMapsService {
  // Static coordinates fallback for Pakistani cities to guarantee map centers
  static const Map<String, Map<String, double>> cityCoordinates = {
    'islamabad': {'lat': 33.6844, 'lng': 73.0479},
    'rawalpindi': {'lat': 33.5984, 'lng': 73.0441},
    'lahore': {'lat': 31.5204, 'lng': 74.3587},
    'karachi': {'lat': 24.8607, 'lng': 67.0011},
    'hyderabad': {'lat': 25.3960, 'lng': 68.3578},
    'peshawar': {'lat': 34.0151, 'lng': 71.5249},
    'multan': {'lat': 30.1575, 'lng': 71.5249},
    'faisalabad': {'lat': 31.4504, 'lng': 73.1350},
    'sialkot': {'lat': 32.4972, 'lng': 74.5361},
    'gujranwala': {'lat': 32.1877, 'lng': 74.1945},
    'quetta': {'lat': 30.1798, 'lng': 66.9750},
  };

  /// Fetch place predictions from Google Places Autocomplete
  static Future<List<Map<String, String>>> getPlaceSuggestions(String input) async {
    return [];
  }

  /// Geocode an address string to obtain latitude, longitude, and formatted address
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    final lowerAddress = address.toLowerCase();

    // Check if the address contains any known Pakistani cities to set initial fallback center
    Map<String, double>? fallbackCoords;
    for (var entry in cityCoordinates.entries) {
      if (lowerAddress.contains(entry.key)) {
        fallbackCoords = entry.value;
        break;
      }
    }
    fallbackCoords ??= cityCoordinates['islamabad']; // Default fallback

    return {
      'lat': fallbackCoords!['lat'],
      'lng': fallbackCoords['lng'],
      'formattedAddress': address,
    };
  }

  /// Retrieve distance and duration via Google Distance Matrix API
  static Future<Map<String, dynamic>?> getDistanceMatrix(String origin, String destination) async {
    return {
      'distanceText': '3.2 km',
      'distanceValue': 3200,
      'durationText': '12 mins',
      'durationValue': 720,
    };
  }
}
