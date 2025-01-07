part of 'pages.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String _secondMessage = 'Semangat Hari Ini!';
  final double initialZoom = AppConstant.defaultInitialZoom;
  final List<Timer> _timers = [];

  int _charIndex = 0;
  String message = 'Please try to functions below.';
  String _displayText = '';
  String _firstMessage = '';
  Duration remainingTime = Duration.zero;

  late UserViewModel userViewModel;
  late Future<LatLng> initialPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userViewModel = Provider.of<UserViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userViewModel.getUserData();
    });
    initialPosition = userViewModel.riceField != null
        ? Future.value(GeoUtil.findPolygonCenter(userViewModel.riceField!.coordinates!))
        : GeoUtil.findCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _firstMessage = 'Selamat Pagi, Guest';
    _checkAnimationStatus();
  }

  @override
  void dispose() {
    // Batalkan semua timer
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  Future<void> _checkAnimationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAnimationShown = prefs.getBool('isAnimationShown') ?? false;

    if (isAnimationShown) {
      // Jika animasi sudah selesai, langsung tampilkan pesan kedua
      setState(() {
        _displayText = _secondMessage;
      });
    } else {
      // Jika belum, mulai animasi
      _startTyping(_firstMessage, onComplete: () {
        Future.delayed(const Duration(seconds: 1), () {
          _startDeleting(onComplete: () {
            _startTyping(_secondMessage, onComplete: () {
              _markAnimationAsShown(); // Tandai animasi selesai
            });
          });
        });
      });
    }
  }

  // Tandai animasi telah selesai
  Future<void> _markAnimationAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAnimationShown', true);
  }

  void _startTyping(String message, {VoidCallback? onComplete}) {
    final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_charIndex < message.length) {
          _displayText = message.substring(0, _charIndex + 1);
          _charIndex++;
        } else {
          timer.cancel();
          _charIndex = 0;
          if (onComplete != null) onComplete();
        }
      });
    });
    _timers.add(timer);
  }

  void _startDeleting({VoidCallback? onComplete}) {
    final timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_displayText.isNotEmpty) {
          _displayText = _displayText.substring(0, _displayText.length - 1);
        } else {
          timer.cancel();
          if (onComplete != null) onComplete();
        }
      });
    });
    _timers.add(timer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _displayText,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<UserViewModel>(builder: (_, userViewModel, __) {
              if (userViewModel.status == Status.loading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF729762)));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengecekan Lahan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    // Container(
                    //     width: MediaQuery.of(context).size.width,
                    //     height: MediaQuery.of(context).size.height * 0.15,
                    //     margin: const EdgeInsets.all(8),
                    //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(16),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.grey.withOpacity(0.2),
                    //           spreadRadius: 1,
                    //           blurRadius: 5,
                    //           offset: const Offset(0, 2), // Efek bayangan
                    //         ),
                    //       ],
                    //     ),
                    //     child: Icon(
                    //       Icons.add_circle,
                    //       size: 50,
                    //     )),
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: FutureBuilder<LatLng>(
                          future: initialPosition,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState != ConnectionState.done) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            return FlutterMap(
                              options: MapOptions(
                                initialCenter: snapshot.data ?? AppConstant.defaultInitialPosition,
                                initialZoom: initialZoom,
                                maxZoom: initialZoom + 3,
                                minZoom: initialZoom - 3,
                              ),
                              children: [
                                AppConstant.openStreeMapTileLayer,
                                if (userViewModel.riceField != null)
                                  buildPolygonLayer(userViewModel.riceField!.coordinates ?? []),
                              ],
                            );
                          }),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hasil Panen',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const LineChartSample(),
                    const Text(
                      'Penghematan Pupuk',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const LineChartSample(),
                    const Text(
                      'Jadwal Pengecekan Tanaman',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Alarm(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildPolygonLayer(List<LatLng> coordinates) {
    return PolygonLayer(polygons: [
      Polygon(
        borderStrokeWidth: 5,
        points: coordinates,
        borderColor: const Color(0xFF00AAFF),
        color: const Color(0xFFFF5252).withOpacity(0.2),
      )
    ]);
  }
}
