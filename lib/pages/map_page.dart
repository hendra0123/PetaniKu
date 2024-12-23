import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:petaniku/shared/shared.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final double initialZoom = 19;

  late AlignOnUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  bool isMapping = false;
  bool showPolygon = true;
  Future<Position> initialPosition = Util.findCurrentPosition();
  List<LatLng> previousPolylinePoints = [];
  List<LatLng> currentPolylinePoints = [];

  void fieldMapping() async {
    if (isMapping) return setState(() => isMapping = false);

    setState(() {
      showPolygon = false;
      isMapping = true;
    });

    while (isMapping) {
      Position currentPosition = await Util.findCurrentPosition();
      LatLng coordinate = LatLng(currentPosition.latitude, currentPosition.longitude);

      // TODO: REMOVE AFTER TESTING
      // LatLng coordinate = UserConstant.coordinate();

      if (previousPolylinePoints.isEmpty && currentPolylinePoints.isEmpty) {
        setState(() {
          previousPolylinePoints.add(coordinate);
          currentPolylinePoints.add(coordinate);
        });
        continue;
      }

      setState(() {
        if (Util.findDistanceBetween(previousPolylinePoints.last, coordinate) >= 10) {
          currentPolylinePoints.clear();
          currentPolylinePoints.add(coordinate);
          previousPolylinePoints.add(coordinate);
        } else {
          if (currentPolylinePoints.length == 2) {
            currentPolylinePoints.removeLast();
          }
          currentPolylinePoints.add(coordinate);
        }
      });

      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      UserConstant.fieldCoordinates = previousPolylinePoints;
      previousPolylinePoints = [];
      currentPolylinePoints = [];
      showPolygon = true;
      isMapping = false;
    });
  }

  void customSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  @override
  void initState() {
    super.initState();
    _followOnLocationUpdate = AlignOnUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Position>(
          future: initialPosition,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            LatLng initialCenter;
            if (snapshot.hasError) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => customSnackbar(snapshot.error!.toString()));
              initialCenter = LatLng(
                  AppConstant.initialPosition.latitude, AppConstant.initialPosition.longitude);
            } else {
              initialCenter = LatLng(
                  AppConstant.initialPosition.latitude, AppConstant.initialPosition.longitude);
              // initialCenter = LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
            }

            return Stack(
              children: [
                FlutterMap(
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: initialZoom,
                      maxZoom: initialZoom + 3,
                      minZoom: initialZoom - 3,
                      // interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
                      onPositionChanged: (MapCamera position, bool hasGesture) {
                        if (hasGesture && _followOnLocationUpdate != AlignOnUpdate.never) {
                          setState(() => _followOnLocationUpdate = AlignOnUpdate.never);
                        }
                      },
                    ),
                    children: [
                      AppConstant.openStreeMapTileLayer,
                      // Constant.mapTilerSatelliteTileLayer,

                      if (isMapping) ...[
                        PolylineLayer(polylines: [
                          Polyline(
                            strokeWidth: 5,
                            points: previousPolylinePoints,
                            color: const Color(0xFF00AAFF),
                          ),
                        ]),
                        PolylineLayer(polylines: [
                          Polyline(
                            strokeWidth: 5,
                            points: currentPolylinePoints,
                            pattern: const StrokePattern.dotted(),
                            color: const Color(0xFF00AAFF),
                          )
                        ]),
                      ],

                      if (showPolygon) ...[
                        UserConstant.fieldCoordinates2.isNotEmpty
                            // polygonPoints.isNotEmpty
                            ? PolygonLayer(polygons: [
                                Polygon(
                                  borderStrokeWidth: 5,
                                  points: UserConstant.fieldCoordinates2,
                                  borderColor: const Color(0xFF00AAFF),
                                  color: const Color(0xFFFF0000).withOpacity(0.3),
                                )
                              ])
                            : const Center(child: Text('Anda belum melakukan pemetaan sawah')),
                      ],

                      // CurrentLocationLayer(
                      //   alignPositionOnUpdate: _followOnLocationUpdate,
                      //   alignPositionStream: _followCurrentLocationStreamController.stream,
                      //   alignDirectionOnUpdate: AlignOnUpdate.never,
                      //   style: const LocationMarkerStyle(
                      //     marker: DefaultLocationMarker(),
                      //     markerSize: Size(20, 20),
                      //     markerDirection: MarkerDirection.heading,
                      //   ),
                      // ),
                    ]),
                Positioned(
                  right: 10,
                  bottom: 58,
                  child: FloatingActionButton(
                      onPressed: () {
                        setState(() => _followOnLocationUpdate = AlignOnUpdate.always);
                        _followCurrentLocationStreamController.add(initialZoom);
                      },
                      child: const Icon(Icons.my_location)),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 115,
                  bottom: 58,
                  child: ElevatedButton(
                    onPressed: () => fieldMapping(),
                    child: Text(isMapping ? "Hentikan pemetaan sawah" : "Mulai pemetaan sawah"),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
