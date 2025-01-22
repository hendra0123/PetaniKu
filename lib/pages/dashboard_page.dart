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
  bool _isAnimationComplete = false;

  late String _firstMessage = '';
  late UserViewModel userViewModel;
  late Future<LatLng> initialCenter;
  late CameraConstraint cameraConstraint;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    userViewModel = Provider.of<UserViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userViewModel.status != Status.error) userViewModel.getUserData();
    });
    if (userViewModel.isRiceFieldPolygonPresent) {
      initialCenter = Future.value(GeoUtil.findPolygonCenter(userViewModel.riceField!.polygon!));
      final cameraBounds = GeoUtil.findPolygonBounds(userViewModel.riceField!.polygon!);
      cameraConstraint =
          CameraConstraint.containCenter(bounds: LatLngBounds(cameraBounds[0], cameraBounds[1]));
    } else {
      initialCenter = GeoUtil.findCurrentPosition();
      cameraConstraint = const CameraConstraint.unconstrained();
    }
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

  Color determineColorLevel(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFEB5600);
      case 2:
        return const Color(0xFFEBA000);
      case 3:
        return const Color(0xFF729762);
      case 4:
        return const Color(0xFF288500);
      case 0:
      default:
        return const Color(0xFF797979);
    }
  }

  String determineRiceCondition(double percentage) {
    String riceCondition;
    if (percentage <= 0.3) {
      riceCondition = "Sangat buruk";
    } else if (percentage > 0.3 && percentage <= 0.6) {
      riceCondition = "Buruk";
    } else if (percentage > 0.6 && percentage <= 0.8) {
      riceCondition = "Baik";
    } else {
      riceCondition = "Optimal";
    }
    return riceCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_displayText),
      ),
      body: Builder(builder: (context) {
        if (userViewModel.status == Status.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF729762)));
        }

        if (userViewModel.status == Status.error) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildText(
                  text: 'Terjadi kesalahan saat proses pengambilan data',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                MainButton(
                  onPressed: () => userViewModel.getUserData(),
                  text: 'Coba Lagi',
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildMap(),
            const SizedBox(height: 16),
            if (!userViewModel.isRiceFieldPolygonPresent) ...[
              _buildText(
                text: "Lakukan Pemetaan Sawah untuk melihat sawah anda pada peta",
                textAlign: TextAlign.center,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
            ],
            MainButton(
              onPressed: () => Navigator.of(context).push(WidgetUtil.getRoute(const MapPage())),
              text: 'Buka Pemetaan Sawah',
            ),
            if (userViewModel.riceLeaves == null || userViewModel.riceLeaves!.isEmpty) ...[
              const SizedBox(height: 32),
              _buildText(
                text: "Pengecekan Terkini",
                fontSize: 20,
              ),
              const SizedBox(height: 16),
              _buildText(
                text: "Informasi pengecekan padi terkini akan ditampilkan di sini",
                textAlign: TextAlign.center,
                fontSize: 16,
              ),
            ],
            if (userViewModel.summary != null) buildCurrentCondition(),
            if (userViewModel.summary != null) buildStatistic(),
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
              cameraConstraint: cameraConstraint,
            ),
            children: [
              AppConstant.mapTilerSatelliteTileLayer,
              if (userViewModel.isRiceFieldPolygonPresent) ...[
                ...buildRiceLeaves(),
                buildRiceField(),
              ]
            ],
          );
        },
      ),
    );
  }

  List<Widget> buildRiceLeaves() {
    final riceLeaves = userViewModel.riceLeaves;
    if (riceLeaves == null || riceLeaves.isEmpty) {
      return [];
    }

    final polygons =
        riceLeaves.where((leaf) => leaf.polygon != null && leaf.polygon!.isNotEmpty).map((leaf) {
      return Polygon(
        points: leaf.polygon!,
        color: determineColorLevel(leaf.level ?? 0),
      );
    }).toList();

    final markers = riceLeaves
        .where((leaf) => leaf.points != null && leaf.points!.isNotEmpty)
        .expand((leaf) => leaf.points!)
        .map(
          (point) => Marker(
            point: point,
            child: const Icon(
              Icons.circle,
              size: 10,
            ),
          ),
        )
        .toList();

    return [PolygonLayer(polygons: polygons), MarkerLayer(markers: markers)];
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

  Widget buildCurrentCondition() {
    final riceLeaves = userViewModel.riceLeaves;
    if (riceLeaves == null || riceLeaves.isEmpty) {
      return const SizedBox.shrink();
    }

    final riceLevels =
        userViewModel.riceLeaves!.where((e) => e.level != null && e.level != 0).map((e) {
      if ((userViewModel.plantingType ?? '') == "Direct Seeded" && e.level! == 3) {
        return 4;
      }
      return e.level!;
    }).toList();
    final levelPercentage = riceLevels.reduce((val, e) => val + e) / (riceLevels.length * 4);

    final currentStatistic = userViewModel.summary!.statistic!.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildText(
          text: "Pengecekan Terakhir",
          fontSize: 24,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoRectangleWidget(
              percentage: levelPercentage,
              header: "Nutrisi Padi",
              footer: determineRiceCondition(levelPercentage),
              backgroundColor: Colors.white,
              borderColor: const Color(0xFF729762),
            ),
            InfoRectangleWidget(
              percentage: currentStatistic.yield! / userViewModel.riceField!.maxYield!,
              header: "Prediksi Panen",
              footer: "${currentStatistic.yield!.ceil()} ton",
              backgroundColor: Colors.white,
              borderColor: const Color(0xFF729762),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Rekomendasi pupuk : ${currentStatistic.ureaRequired!.round()} kg",
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Tanggal : ${currentStatistic.createdTime!.formatToCustomString()}",
        ),
      ],
    );
  }

  Widget buildStatistic() {
    final statistic = userViewModel.statisic;
    if (statistic == null || statistic.isEmpty) {
      return const SizedBox.shrink();
    }

    final yields =
        userViewModel.statisic!.where((e) => e.yield != null).map((e) => e.yield!).toList();
    final ureas = userViewModel.statisic!
        .where((e) => e.ureaRequired != null)
        .map((e) => e.ureaRequired!)
        .toList();
    final createdTimes = userViewModel.statisic!
        .where((e) => e.createdTime != null)
        .map((e) => e.createdTime!)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildText(
          text: "Tingkat Hasil Panen (Ton)",
          fontSize: 24,
        ),
        CustomLineChart(
          mainData: yields,
          dataDates: createdTimes,
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Penghematan Pupuk (Kg)",
          fontSize: 24,
        ),
        CustomLineChart(
          mainData: ureas,
          dataDates: createdTimes,
        ),
      ],
    );
  }

  Widget buildAlarm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildText(
          text: "Jadwal Pengecekan Tanaman",
          fontSize: 24,
        ),
        const SizedBox(height: 16),
        const Alarm(),
      ],
    );
  }

  Text _buildText({
    required String text,
    TextAlign? textAlign,
    FontWeight fontWeight = FontWeight.bold,
    double fontSize = 18,
    Color? color,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
