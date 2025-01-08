part of 'pages.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String _secondMessage = 'Semangat Hari Ini!';
  final double initialZoom = AppConstant.defaultInitialZoom - 1;
  final List<Timer> _timers = [];

  int _charIndex = 0;
  String message = 'Please try to functions below.';
  String _displayText = '';
  bool _isAnimationComplete = false;

  late String _firstMessage = '';
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
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _firstMessage = 'Selamat Pagi, ${userViewModel.user?.name ?? 'Guest'}';
    if (_isAnimationComplete) {
      // Jika animasi sudah selesai, langsung tampilkan pesan kedua
      setState(() {
        _displayText = _secondMessage;
      });
    } else {
      // Jika belum, mulai animasi
      _startWelcomeAnimation();
    }
  }

  @override
  void dispose() {
    // Hentikan semua timer untuk mencegah memory leak
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  void _startWelcomeAnimation() {
    _startTyping(_firstMessage, onComplete: () {
      Future.delayed(const Duration(seconds: 1), () {
        _startDeleting(onComplete: () {
          _startTyping(_secondMessage, onComplete: () {
            setState(() {
              _isAnimationComplete = true; // Tandai animasi selesai
            });
          });
        });
      });
    });
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
        title: Text(_displayText),
      ),
      body: Consumer<UserViewModel>(builder: (_, userViewModel, __) {
        if (userViewModel.status == Status.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF729762)));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          children: [
            buildMap(),
            const SizedBox(height: 16),
            MainButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/map");
              },
              text: 'Buka Pemetaan Sawah',
            ),
            const SizedBox(height: 16),
            if (userViewModel.summary != null) buildCurrentCondition(),
            const SizedBox(height: 16),
            buildStatistics(),
            const SizedBox(height: 16),
            buildAlarm(),
          ],
        );
      }),
    );
  }

  Widget buildMap() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
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
              cameraConstraint: CameraConstraint.containCenter(
                  bounds: LatLngBounds(const LatLng(-5.147, 119.4), const LatLng(-5.148, 119.401))),
            ),
            children: [
              AppConstant.openStreeMapTileLayer,
              if (userViewModel.riceField != null)
                PolygonLayer(polygons: [
                  Polygon(
                    borderStrokeWidth: 5,
                    points: userViewModel.riceField!.coordinates ?? [],
                    borderColor: const Color(0xFF00AAFF),
                    color: const Color(0xFFFF5252).withOpacity(0.2),
                  )
                ])
            ],
          );
        },
      ),
    );
  }

  Widget buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText(
          text: 'Hasil Panen',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const LineChartSample(),
        _buildText(
          text: 'Penghematan Pupuk',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const LineChartSample(),
      ],
    );
  }

  Widget buildCurrentCondition() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText(
          text: 'Kondisi Terkini',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const SizedBox(height: 16),
        _buildText(
          text: 'Padi anda kekurangan nutrisi',
        ),
        const SizedBox(height: 8),
        _buildText(
          text: 'Rekomendasi jumlah pupuk',
        ),
        _buildText(
          text: '${userViewModel.summary!.statistics![0].ureaRequired!.ceil()} kg',
        ),
        const SizedBox(height: 8),
        _buildText(
          text: 'Prediksi panen',
        ),
        _buildText(
          text: '${userViewModel.summary!.statistics![0].yields!} ton',
        ),
        const SizedBox(height: 8),
        _buildText(
          text: 'Tanggal terakhir pengecekan',
        ),
        _buildText(
          text: '${userViewModel.summary!.statistics![0].createdTime!}',
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget buildAlarm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText(
          text: 'Jadwal Pengecekan Tanaman',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const SizedBox(height: 10),
        const Alarm(),
      ],
    );
  }

  Text _buildText(
      {required String text,
      FontWeight fontWeight = FontWeight.normal,
      double fontSize = 18,
      Color color = Colors.black}) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
