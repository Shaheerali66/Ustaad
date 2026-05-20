import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

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
    if (input.trim().isEmpty) return [];

    final completer = Completer<List<Map<String, String>>>();
    try {
      if (js.context.hasProperty('getPlaceSuggestions')) {
        js.context.callMethod('getPlaceSuggestions', [
          input,
          js.JsFunction.withThis((_, predictions) {
            final list = <Map<String, String>>[];
            if (predictions is js.JsArray) {
              for (var i = 0; i < predictions.length; i++) {
                final item = predictions[i] as js.JsObject;
                list.add({
                  'description': item['description']?.toString() ?? '',
                  'placeId': item['placeId']?.toString() ?? '',
                });
              }
            }
            completer.complete(list);
          })
        ]);
      } else {
        completer.complete([]);
      }
    } catch (e) {
      debugPrint('GoogleMapsService autocomplete error: $e');
      completer.complete([]);
    }
    return completer.future;
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

    final completer = Completer<Map<String, dynamic>?>();
    try {
      if (js.context.hasProperty('geocodeAddress')) {
        js.context.callMethod('geocodeAddress', [
          address,
          js.JsFunction.withThis((_, result) {
            if (result != null) {
              final jsResult = result as js.JsObject;
              completer.complete({
                'lat': jsResult['lat'] as double,
                'lng': jsResult['lng'] as double,
                'formattedAddress': jsResult['formattedAddress']?.toString() ?? address,
              });
            } else {
              // Return fallback coordinates if Geocoding API returns null
              completer.complete({
                'lat': fallbackCoords!['lat'],
                'lng': fallbackCoords['lng'],
                'formattedAddress': address,
              });
            }
          })
        ]);
      } else {
        completer.complete({
          'lat': fallbackCoords!['lat'],
          'lng': fallbackCoords['lng'],
          'formattedAddress': address,
        });
      }
    } catch (e) {
      debugPrint('GoogleMapsService geocoding error: $e');
      completer.complete({
        'lat': fallbackCoords!['lat'],
        'lng': fallbackCoords['lng'],
        'formattedAddress': address,
      });
    }
    return completer.future;
  }

  /// Retrieve distance and duration via Google Distance Matrix API
  static Future<Map<String, dynamic>?> getDistanceMatrix(String origin, String destination) async {
    final completer = Completer<Map<String, dynamic>?>();
    try {
      if (js.context.hasProperty('getDistanceMatrix')) {
        js.context.callMethod('getDistanceMatrix', [
          origin,
          destination,
          js.JsFunction.withThis((_, result) {
            if (result != null) {
              final jsResult = result as js.JsObject;
              completer.complete({
                'distanceText': jsResult['distanceText']?.toString() ?? '',
                'distanceValue': jsResult['distanceValue'] as int? ?? 0,
                'durationText': jsResult['durationText']?.toString() ?? '',
                'durationValue': jsResult['durationValue'] as int? ?? 0,
              });
            } else {
              completer.complete(null);
            }
          })
        ]);
      } else {
        completer.complete(null);
      }
    } catch (e) {
      debugPrint('GoogleMapsService distance matrix error: $e');
      completer.complete(null);
    }
    return completer.future;
  }
}
