import 'dart:js' as js;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
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
  late String _viewType;
  late String _containerId;

  @override
  void initState() {
    super.initState();
    final uniqueId = DateTime.now().microsecondsSinceEpoch;
    _viewType = 'google-map-$uniqueId';
    _containerId = 'map-container-$uniqueId';

    // Register platform view factory for Google Map div element
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final div = html.DivElement()
        ..id = _containerId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.minHeight = '300px'
        ..style.minWidth = '100%'
        ..style.position = 'relative'
        ..style.display = 'block'
        ..style.backgroundColor = '#E8F1E9'
        ..style.borderRadius = widget.borderRadius != null ? '${widget.borderRadius!.topLeft.x}px' : '16px';
      return div;
    });

    _initializeMapDelayed();
  }

  @override
  void didUpdateWidget(covariant GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerLat != widget.centerLat ||
        oldWidget.centerLng != widget.centerLng ||
        oldWidget.zoom != widget.zoom ||
        oldWidget.markers.length != widget.markers.length ||
        oldWidget.route != widget.route) {
      _initializeMapDelayed();
    }
  }

  void _initializeMapDelayed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Call the JS function to render the map
      try {
        if (js.context.hasProperty('initializeGoogleMap')) {
          js.context.callMethod('initializeGoogleMap', [
            _containerId,
            widget.centerLat,
            widget.centerLng,
            widget.zoom,
            js.JsObject.jsify(widget.markers),
            widget.route != null ? js.JsObject.jsify(widget.route!) : null,
          ]);
        }
      } catch (e) {
        debugPrint('Error calling initializeGoogleMap: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double displayHeight = widget.height < 300 ? 300 : widget.height;
    return Container(
      height: displayHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
