import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:petaniku/models/models.dart';
import 'package:petaniku/shared/shared.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final StreamController<double?> _followCurrentLocationStreamController =
      StreamController<double?>.broadcast();

  AlignOnUpdate _followOnLocationUpdate = AlignOnUpdate.always;
  RiceField? currentRiceField = UserConstant.riceField;
  double initialZoom = AppConstant.defaultInitialZoom;
  List<LatLng> previousPolylinePoints = [];
  List<LatLng> currentPolylinePoints = [];
  String polygonErrorMsg = "";
  bool isCancelled = false;
  bool showPolygon = true;
  bool isMapping = false;

  late Future<LatLng> initialPosition;

  void fieldMapping() async {
    if (isMapping && polygonErrorMsg.isEmpty) {
      return setState(() => isMapping = false);
    }

    setState(() {
      isMapping = true;
      showPolygon = false;
      isCancelled = false;
      polygonErrorMsg = "";
      currentRiceField = RiceField(area: 0, coordinates: const [], createdTime: DateTime.now());
    });

    while (isMapping) {
      try {
        // TODO: REPAIR AFTER TESTING
        await GeoUtil.findCurrentPosition();
        // LatLng coordinate = await GeoUtil.findCurrentPosition();
        LatLng coordinate = UserConstant.getCoord();

        if (previousPolylinePoints.isEmpty && currentPolylinePoints.isEmpty) {
          previousPolylinePoints.add(coordinate);
          currentPolylinePoints.add(coordinate);
          continue;
        }

        setState(() {
          if (GeoUtil.findDistanceBetween(previousPolylinePoints.last, coordinate) >= 10) {
            previousPolylinePoints.add(coordinate);
            currentPolylinePoints = [coordinate];
          } else {
            if (currentPolylinePoints.length == 2) {
              currentPolylinePoints.removeLast();
            }
            currentPolylinePoints.add(coordinate);
          }
        });

        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        return setState(() => polygonErrorMsg = e.toString());
      }
    }

    setState(() {
      if (!isCancelled) {
        if (previousPolylinePoints.isNotEmpty) {
          previousPolylinePoints.add(previousPolylinePoints.first);
          previousPolylinePoints = GeoUtil.simplifyPolygon(previousPolylinePoints);
        }
        double riceFieldArea;
        if (GeoUtil.isValidPolygon(previousPolylinePoints)) {
          riceFieldArea = GeoUtil.findPolygonArea(previousPolylinePoints);
        } else {
          riceFieldArea = 0;
          polygonErrorMsg = "Pemetaan sawah tidak benar";
        }
        currentRiceField = RiceField(
          area: riceFieldArea,
          coordinates: previousPolylinePoints,
          createdTime: DateTime.now(),
        );
      }

      showPolygon = true;
      currentPolylinePoints = [];
      previousPolylinePoints = [];
      UserConstant.index = 0;
    });
  }

  void finalizeMapping() {
    setState(() {
      if (previousPolylinePoints.isNotEmpty) {
        previousPolylinePoints.add(previousPolylinePoints.first);
        previousPolylinePoints = GeoUtil.simplifyPolygon(previousPolylinePoints);
      }

      if (GeoUtil.isValidPolygon(previousPolylinePoints)) {
        currentRiceField = RiceField(
          area: GeoUtil.findPolygonArea(previousPolylinePoints),
          coordinates: previousPolylinePoints,
          createdTime: DateTime.now(),
        );
      } else {
        polygonErrorMsg = "Pemetaan sawah tidak benar";
      }
    });
  }

  void resetMappingState() {
    setState(() {
      showPolygon = true;
      currentPolylinePoints.clear();
      previousPolylinePoints.clear();
      UserConstant.index = 0;
    });
  }

  void cancelFieldMapping() {
    setState(() {
      currentRiceField = UserConstant.riceField;
      polygonErrorMsg = "";
      isCancelled = true;
      isMapping = false;
      resetMappingState();
    });
  }

  void saveRiceField() {
    // TODO: CONNECT TO SERVER
    setState(() => UserConstant.setRiceField(currentRiceField));
  }

  @override
  void initState() {
    super.initState();
    initialPosition = currentRiceField != null
        ? Future.value(GeoUtil.findPolygonCenter(currentRiceField!.coordinates!))
        : GeoUtil.findCurrentPosition();
  }

  @override
  void dispose() {
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LatLng>(
          future: initialPosition,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              polygonErrorMsg = snapshot.error.toString();
            }

            return Stack(children: [
              buildMap(snapshot.data),
              buildBottomAlignedInfo(),
              buildFloatingButton(),
            ]);
          }),
    );
  }

  Widget buildMap(LatLng? position) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: position ?? AppConstant.defaultInitialPosition,
        initialZoom: initialZoom,
        maxZoom: initialZoom + 3,
        minZoom: initialZoom - 3,
        onPositionChanged: (MapCamera position, bool hasGesture) {
          if (hasGesture && _followOnLocationUpdate != AlignOnUpdate.never) {
            setState(() => _followOnLocationUpdate = AlignOnUpdate.never);
          }
        },
      ),
      children: [
        AppConstant.openStreeMapTileLayer,
        if (isMapping) ...buildPolylineLayers(),
        if (showPolygon && currentRiceField != null) buildPolygonLayer(),
        // TODO: UNCOMMENT AFTER TESTING
        // if (isMapping || currentRiceField == null) buildCurrentLocationLayer(),
      ],
    );
  }

  List<Widget> buildPolylineLayers() {
    return [
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
      ])
    ];
  }

  Widget buildPolygonLayer() {
    return PolygonLayer(polygons: [
      Polygon(
        borderStrokeWidth: 5,
        points: currentRiceField!.coordinates!,
        borderColor: const Color(0xFF00AAFF),
        color: const Color(0xFFFF5252).withOpacity(0.2),
      )
    ]);
  }

  Widget buildCurrentLocationLayer() {
    return CurrentLocationLayer(
      alignPositionOnUpdate: _followOnLocationUpdate,
      alignPositionStream: _followCurrentLocationStreamController.stream,
      alignDirectionOnUpdate: AlignOnUpdate.never,
      style: const LocationMarkerStyle(
        marker: DefaultLocationMarker(),
        markerSize: Size(20, 20),
        markerDirection: MarkerDirection.heading,
      ),
    );
  }

  Widget buildBottomAlignedInfo() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        color: const Color(0xFFF7F9FC),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          buildRiceFieldInfo(),
          const SizedBox(height: 32),
          buildMainButtons(),
        ]),
      ),
    );
  }

  Widget buildRiceFieldInfo() {
    return SizedBox(
      width: double.infinity,
      child: polygonErrorMsg.isNotEmpty
          ? buildText(text: polygonErrorMsg)
          : isMapping
              ? buildText(text: "Kelilingi sawah anda agar sistem dapat memetakannya")
              : currentRiceField != null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      buildText(
                        text: "${currentRiceField!.area!} Hektar",
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                      buildText(
                        text:
                            "Tanggal Pemetaan: ${currentRiceField!.createdTime!.day}/${currentRiceField!.createdTime!.month}/${currentRiceField!.createdTime!.year}",
                      ),
                    ])
                  : buildText(text: "Anda belum melakukan pemetaan sawah"),
    );
  }

  Widget buildMainButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      if (currentRiceField != UserConstant.riceField) ...[
        buildExpandedButton(
          onPressed: cancelFieldMapping,
          buttonColor: Colors.grey,
          text: "Batal",
        ),
        const SizedBox(width: 16)
      ],
      buildExpandedButton(
        onPressed:
            !isMapping && polygonErrorMsg.isEmpty && currentRiceField != UserConstant.riceField
                ? saveRiceField
                : fieldMapping,
        buttonColor: Color(polygonErrorMsg.isEmpty ? 0xFF729762 : 0xFFEBA000),
        text: isMapping
            ? polygonErrorMsg.isNotEmpty
                ? "Lanjutkan"
                : "Selesai"
            : polygonErrorMsg.isNotEmpty
                ? "Ulangi"
                : currentRiceField != UserConstant.riceField
                    ? "Konfirmasi"
                    : "Mulai Pemetaan Sawah",
      ),
    ]);
  }

  Widget buildFloatingButton() {
    return Positioned(
      right: 24,
      bottom: 216,
      child: FloatingActionButton(
        onPressed: () {
          setState(() => _followOnLocationUpdate = AlignOnUpdate.always);
          _followCurrentLocationStreamController.add(initialZoom);
        },
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFE7F0DC),
        child: const Icon(
          Icons.my_location_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buildText({
    required String text,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return Text(text,
        style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: color,
        ));
  }

  Widget buildExpandedButton({
    required void Function()? onPressed,
    required Color buttonColor,
    required String text,
  }) {
    return Expanded(
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: buttonColor,
          ),
          child: buildText(
            text: text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
    );
  }
}
