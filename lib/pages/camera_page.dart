part of 'pages.dart';

class CameraPage extends StatefulWidget {
  final VoidCallback backToDashboard;

  const CameraPage({super.key, required this.backToDashboard});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final double initialZoom = AppConstant.defaultInitialZoom;
  final AlignOnUpdate _followOnLocationUpdate = AlignOnUpdate.always;
  final StreamController<double?> _followCurrentLocationStreamController =
      StreamController<double?>.broadcast();
  final Stream<Position> _positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );
  final List<XFile> _capturedImages = [];
  final List<LatLng> _imagePositions = [];

  Future<LatLng> initialPosition = GeoUtil.findCurrentPosition();
  String _positionErrorMsg = "";
  bool _isInCameraMode = true;
  bool _isLoading = false;
  bool _isInsideRiceField = false;

  late Future<void> _initializeControllerFuture;
  late CameraController _cameraController;
  late UserViewModel userViewModel;

  void startListeningToPositionChanges() {
    _positionStream.listen((Position position) {
      _checkCurrentPosition(LatLng(position.latitude, position.longitude));
    });
  }

  void _checkCurrentPosition(LatLng newLocation) async {
    if (!mounted) return;
    if (!userViewModel.isRiceFieldPolygonPresent) {
      _setUserPositionStatus(false, "Anda harus melakukan Pemetaan Sawah dahulu");
      return;
    }

    bool isLocationValid = GeoUtil.isInsidePolygon(userViewModel.riceField!.polygon!, newLocation);
    if (isLocationValid) {
    } else if (!isLocationValid) {
      _setUserPositionStatus(false, "Anda harus berada di dalam lokasi sawah");
    }
  }

  void _setUserPositionStatus(bool status, String message) {
    setState(() {
      _isInsideRiceField = status;
      _positionErrorMsg = message;
    });
  }

  Future<void> _takePicture() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final currentPosition = await GeoUtil.findCurrentPosition();
      if (!GeoUtil.isInsidePolygon(userViewModel.riceField!.polygon!, currentPosition) && mounted) {
        _setUserPositionStatus(false, "Anda harus berada di dalam lokasi sawah");
        setState(() => _isLoading = false);
        return;
      }

      final image = await _cameraController.takePicture();
      if (mounted) {
        setState(() {
          _imagePositions.add(currentPosition);
          _capturedImages.add(image);
          _isInCameraMode = false; // Kembali ke tampilan grid setelah foto
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) WidgetUtil.showSnackBar(context, e.toString(), Colors.red);
    }
  }

  void _enterCameraMode() {
    if (_capturedImages.length < 10) {
      setState(() {
        _isInCameraMode = true;
      });
    } else {
      WidgetUtil.showSnackBar(context, "Anda hanya dapat mengambil maksimal 10 foto.", Colors.red);
    }
  }

  void _viewImageFullscreen(String imagePath) {
    Navigator.of(context).push(WidgetUtil.getRoute(FullScreenImageView(imagePath: imagePath)));
  }

  void _navigateToFormPlant() async {
    final imageFiles = _capturedImages.map((xfile) => File(xfile.path)).toList();
    final result = await Navigator.of(context).push(
      WidgetUtil.getRoute(FormPlant(images: imageFiles, points: _imagePositions)),
    );

    if (result != null && result.runtimeType == Prediction && mounted) {
      setState(() {
        _capturedImages.clear();
        _imagePositions.clear();
        _isInCameraMode = true;
      });
      widget.backToDashboard();
      Navigator.of(context).push(WidgetUtil.getRoute(const MapPage()));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userViewModel = Provider.of<UserViewModel>(context);
    GeoUtil.findCurrentPosition().then((value) => _checkCurrentPosition(value));
  }

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      AppConstant.cameraDesc,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _cameraController.initialize();
    startListeningToPositionChanges();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Kamera"),
      ),
      body: _isInCameraMode
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CameraPreview(_cameraController),
                      ),
                      if (!_isInsideRiceField)
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.red,
                                ),
                                child: Center(
                                  child: Text(
                                    _positionErrorMsg,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: MainButton(
                            onPressed: _isInsideRiceField ? _takePicture : null,
                            buttonWidth: double.infinity,
                            text: 'Ambil Foto',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: buildMap(),
                      ),
                      if (_isLoading) _buildLoadingOverlay()
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF729762)));
                }
              },
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _capturedImages.length < 10
                        ? _capturedImages.length + 1
                        : _capturedImages.length,
                    itemBuilder: (context, index) {
                      if (index < _capturedImages.length) {
                        return GestureDetector(
                          onTap: () => _viewImageFullscreen(_capturedImages[index].path),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(
                              File(_capturedImages[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: _enterCameraMode,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green, width: 2)),
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.green, size: 50),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: MainButton(
                    onPressed: _navigateToFormPlant,
                    text: 'Kirim Foto',
                    buttonWidth: double.infinity,
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildMap() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder<LatLng>(
        future: initialPosition,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF729762)));
          }

          if (snapshot.hasError) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  initialPosition = GeoUtil.findCurrentPosition();
                });
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restart_alt_outlined,
                    size: 50,
                  ),
                  Text('Muat ulang peta'),
                ],
              ),
            );
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: snapshot.data ?? AppConstant.defaultInitialPosition,
              initialZoom: initialZoom,
              maxZoom: initialZoom + 3,
              minZoom: initialZoom - 1,
            ),
            children: [
              AppConstant.mapTilerSatelliteTileLayer,
              if (userViewModel.isRiceFieldPolygonPresent) buildRiceField(),
              buildCurrentLocationLayer(),
            ],
          );
        },
      ),
    );
  }

  Widget buildRiceField() {
    return PolygonLayer(
      polygons: [
        Polygon(
          borderStrokeWidth: 5,
          points: userViewModel.riceField!.polygon!,
          borderColor: const Color(0xFF00AAFF),
          color: Colors.black.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget buildCurrentLocationLayer() {
    return CurrentLocationLayer(
      alignPositionStream: _followCurrentLocationStreamController.stream,
      alignPositionOnUpdate: _followOnLocationUpdate,
      alignDirectionOnUpdate: AlignOnUpdate.never,
      style: const LocationMarkerStyle(
        marker: DefaultLocationMarker(),
        markerSize: Size(20, 20),
        markerDirection: MarkerDirection.heading,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF729762)),
      ),
    );
  }
}
