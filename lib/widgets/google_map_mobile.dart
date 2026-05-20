import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_colors.dart';

class GoogleMapWidget extends StatefulWidget {
  final double centerLat;
  final double centerLng;
  final double zoom;
  final List<Map<String, dynamic>> markers;
  final Map<String, dynamic>? route;
  final double height;
  final BorderRadius? borderRadius;

  const GoogleMapWidget({
    super.key,
    required this.centerLat,
    required this.centerLng,
    this.zoom = 13,
    this.markers = const [],
    this.route,
    this.height = 300,
    this.borderRadius,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutePoints();
  }

  @override
  void didUpdateWidget(covariant GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerLat != widget.centerLat ||
        oldWidget.centerLng != widget.centerLng ||
        oldWidget.zoom != widget.zoom) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(widget.centerLat, widget.centerLng),
          widget.zoom,
        ),
      );
    }
    if (oldWidget.route != widget.route) {
      _fetchRoutePoints();
    }
  }

  Future<void> _fetchRoutePoints() async {
    final route = widget.route;
    if (route == null || route['origin'] == null || route['destination'] == null) {
      if (mounted) {
        setState(() {
          _routePoints = [];
        });
      }
      return;
    }

    try {
      final origin = route['origin'];
      final destination = route['destination'];
      final double originLat = (origin['lat'] as num).toDouble();
      final double originLng = (origin['lng'] as num).toDouble();
      final double destLat = (destination['lat'] as num).toDouble();
      final double destLng = (destination['lng'] as num).toDouble();

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$originLat,$originLng'
        '&destination=$destLat,$destLng'
        '&key=AIzaSyCfyfXA-jSL2Gwc9p3lML2V6z-AwKW0m0w'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final pointsStr = data['routes'][0]['overview_polyline']['points'] as String;
          final decoded = _decodePolyline(pointsStr);
          if (mounted) {
            setState(() {
              _routePoints = decoded;
            });
          }
        } else {
          debugPrint('Directions API status error: ${data['status']}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching route points on mobile: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    for (var i = 0; i < widget.markers.length; i++) {
      final m = widget.markers[i];
      final double lat = (m['lat'] as num).toDouble();
      final double lng = (m['lng'] as num).toDouble();
      final String title = m['title']?.toString() ?? 'Location';
      final String color = m['color']?.toString() ?? '';

      double hue = BitmapDescriptor.hueRed;
      if (color == 'blue') {
        hue = BitmapDescriptor.hueBlue;
      }

      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        ),
      );
    }

    // Fallback if no markers: add a default center marker
    if (markers.isEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('center_marker'),
          position: LatLng(widget.centerLat, widget.centerLng),
          infoWindow: const InfoWindow(title: 'Selected Location'),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route_polyline'),
        points: _routePoints,
        color: const Color(0xFF4285F4), // Google Blue
        width: 6,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final double displayHeight = widget.height < 300 ? 300 : widget.height;
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    return Container(
      height: displayHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AppColors.surfaceVariant),
        color: const Color(0xFFE8F1E9), // Google Maps light background green-ish color
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Real GoogleMap Widget
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.centerLat, widget.centerLng),
                  zoom: widget.zoom,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: _buildMarkers(),
                polylines: _buildPolylines(),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
            // Mock Search Bar Overlay
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.markers.isNotEmpty
                            ? 'Navigating to Customer...'
                            : 'Search destination...',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    const Icon(Icons.mic, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
            // Mock Location Card Overlay at bottom
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'USTAAD Navigation Mode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.route != null
                                ? 'Directions loaded. Routing worker to customer.'
                                : 'Coordinates: ${widget.centerLat.toStringAsFixed(4)}, ${widget.centerLng.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Compass and Zoom Buttons Overlay on the side
            Positioned(
              right: 12,
              top: 70,
              child: Column(
                children: [
                  _circleButton(Icons.explore, Colors.white, Colors.black87, () {
                    // Reset compass
                  }),
                  const SizedBox(height: 8),
                  _circleButton(Icons.add, Colors.white, Colors.black87, () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  }),
                  const SizedBox(height: 4),
                  _circleButton(Icons.remove, Colors.white, Colors.black87, () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, color: fg, size: 18),
      ),
    );
  }
}
