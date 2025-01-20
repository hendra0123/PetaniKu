part of 'pages.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final StreamController<double?> _followCurrentLocationStreamController =
      StreamController<double?>.broadcast();

  AlignOnUpdate _followOnLocationUpdate = AlignOnUpdate.always;
  double initialZoom = AppConstant.defaultInitialZoom;
  List<LatLng> previousPolylinePoints = [];
  List<LatLng> currentPolylinePoints = [];
  String polygonErrorMsg = "";
  bool isCancelled = false;
  bool showPolygon = true;
  bool isMapping = false;

  late UserViewModel userViewModel;
  late RiceField? currentRiceField;
  late Future<LatLng> initialCenter;

  void fieldMapping() async {
    if (isMapping && polygonErrorMsg.isEmpty && mounted) {
      setState(() => isMapping = false);
      return;
    }

    if (mounted) {
      setState(() {
        isMapping = true;
        showPolygon = false;
        isCancelled = false;
        polygonErrorMsg = "";
        currentRiceField = RiceField(area: 0, polygon: const [], createdTime: DateTime.now());
      });
      followCurrentLocation();
    }

    while (isMapping && mounted) {
      try {
        LatLng coordinate = await GeoUtil.findCurrentPosition();

        if (previousPolylinePoints.isEmpty && currentPolylinePoints.isEmpty) {
          previousPolylinePoints.add(coordinate);
          currentPolylinePoints.add(coordinate);
          continue;
        }

        if (mounted) {
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
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        if (mounted) setState(() => polygonErrorMsg = e.toString());
        break;
      }
    }

    if (!mounted) return;

    if (!isCancelled && previousPolylinePoints.isNotEmpty) {
      finalizeMapping();
    }
    resetMappingState();
  }

  void finalizeMapping() {
    setState(() {
      previousPolylinePoints.add(previousPolylinePoints.first);
      previousPolylinePoints = GeoUtil.simplifyPolygon(previousPolylinePoints);
      if (GeoUtil.isValidPolygon(previousPolylinePoints)) {
        currentRiceField = RiceField(
          area: GeoUtil.findPolygonArea(previousPolylinePoints),
          polygon: List.from(previousPolylinePoints),
          createdTime: DateTime.now(),
        );
      } else {
        currentRiceField = RiceField(polygon: List.from(previousPolylinePoints));
        polygonErrorMsg = "Pemetaan sawah tidak benar";
      }
    });
  }

  void resetMappingState() {
    setState(() {
      showPolygon = true;
      currentPolylinePoints.clear();
      previousPolylinePoints.clear();
    });
  }

  void cancelFieldMapping() {
    initializeLateData();
    setState(() {
      polygonErrorMsg = "";
      isCancelled = true;
      isMapping = false;
      resetMappingState();
    });
  }

  void saveRiceField() async {
    try {
      String message = await userViewModel.updateRiceField(currentRiceField!);
      if (mounted) WidgetUtil.showSnackBar(context, message, null);
    } catch (e) {
      if (mounted) WidgetUtil.showSnackBar(context, e.toString(), Colors.red);
    }
  }

  void followCurrentLocation() {
    setState(() => _followOnLocationUpdate = AlignOnUpdate.always);
    _followCurrentLocationStreamController.add(initialZoom);
  }

  void initializeLateData() {
    currentRiceField = userViewModel.riceField;
    initialCenter = userViewModel.isRiceFieldPolygonPresent
        ? Future.value(GeoUtil.findPolygonCenter(currentRiceField!.polygon!))
        : GeoUtil.findCurrentPosition();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userViewModel = Provider.of<UserViewModel>(context);
    initializeLateData();
  }

  @override
  void dispose() {
    isMapping = false;
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pemetaan Sawah"),
        leading: const BackButton(),
      ),
      body: Stack(children: [
        buildMap(),
        buildBottomAlignedInfo(),
        buildFloatingButton(),
      ]),
    );
  }

  Widget buildMap() {
    return FutureBuilder<LatLng>(
        future: initialCenter,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: snapshot.data ?? AppConstant.defaultInitialPosition,
              initialZoom: initialZoom,
              maxZoom: initialZoom + 3,
              minZoom: initialZoom - 1,
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
              if (isMapping || currentRiceField == null) buildCurrentLocationLayer(),
            ],
          );
        });
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
        points: currentRiceField!.polygon!,
        borderColor: const Color(0xFF00AAFF),
        color: Colors.black.withOpacity(0.2),
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
                        text: "${currentRiceField?.area} Hektar",
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                      buildText(
                        text: "Tanggal: ${currentRiceField?.createdTime?.formatToCustomString()}",
                      ),
                    ])
                  : buildText(text: "Anda belum melakukan pemetaan sawah"),
    );
  }

  Widget buildMainButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      if (currentRiceField != userViewModel.riceField) ...[
        MainButton(
          onPressed: cancelFieldMapping,
          buttonColor: Colors.grey,
          isExpanded: true,
          text: "Batal",
        ),
        const SizedBox(width: 16)
      ],
      MainButton(
        onPressed:
            !isMapping && polygonErrorMsg.isEmpty && currentRiceField != userViewModel.riceField
                ? saveRiceField
                : fieldMapping,
        buttonColor: Color(polygonErrorMsg.isEmpty ? 0xFF729762 : 0xFFEBA000),
        isExpanded: true,
        text: isMapping
            ? polygonErrorMsg.isNotEmpty
                ? "Lanjutkan"
                : "Selesai"
            : polygonErrorMsg.isNotEmpty
                ? "Ulangi"
                : currentRiceField != userViewModel.riceField
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
        onPressed: followCurrentLocation,
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
}
