part of 'pages.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  final String _secondMessage = 'Semangat Hari Ini!';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<String> selectedDays = [];
  List<DateTime> targetDates = [];
  List<Timer> _timers = [];
  bool isAlarmEnabled = false;
  // bool _isTyping = true;
  int _charIndex = 0;
  int selectedHour = 9;
  int selectedMinute = 0;
  int indexTargetDates = 0;
  String message = 'Please try to functions below.';
  String _displayText = '';
  // bool _isTyping = true;
  String _firstMessage = '';

  bool _isAnimationComplete = false;
  late UserViewModel userViewModel;

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return;
    }

    if (!status.isGranted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Izin Diperlukan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              "Aplikasi membutuhkan izin untuk mengakses notifikasi handphone Anda agar dapat berfungsi dengan baik. Buka Pengaturan > Izin > Notifikasi > Izinkan Notifikasi"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Kembali"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userViewModel = Provider.of<UserViewModel>(context);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => userViewModel.getUserData());
  }

  @override
  void initState() {
    super.initState();
    initializeNotifications();
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

  // Inisialisasi notifikasi dan timezone
  void initializeNotifications() async {
    // Inisialisasi plugin notifikasi
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Inisialisasi timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Makassar')); // Atur ke zona WITA
  }

  // Fungsi untuk menjadwalkan notifikasi (dimodifikasi)
  Future<void> scheduleNotification() async {
    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu hari untuk alarm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarm Notifications',
      channelDescription: 'Notifikasi alarm untuk jadwal pengecekan tanaman',
      importance: Importance.high,
      priority: Priority.high,
      channelShowBadge: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    targetDates = [];
    indexTargetDates = 0;

    for (String day in selectedDays) {
      int weekday = days.indexOf(day) + 1; // Senin = 1, Minggu = 7
      final now = DateTime.now();

      // Hitung tanggal target
      DateTime targetDate;

      if (weekday == now.weekday) {
        // Hari yang sama dengan hari ini
        if (selectedHour > now.hour ||
            (selectedHour == now.hour && selectedMinute > now.minute)) {
          // Jika waktu belum lewat
          targetDate = DateTime(
              now.year, now.month, now.day, selectedHour, selectedMinute);
        } else {
          // Jika waktu sudah lewat, pindahkan ke minggu depan
          targetDate = now.add(Duration(days: 7));
          targetDate = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day - targetDate.weekday + weekday,
              selectedHour,
              selectedMinute);
        }
      } else if (weekday > now.weekday) {
        // Hari di minggu ini
        int daysUntil = weekday - now.weekday;
        targetDate = now.add(Duration(days: daysUntil));
        targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day,
            selectedHour, selectedMinute);
      } else {
        // Hari di minggu depan
        int daysUntilNextWeek = 7 - (now.weekday - weekday);
        targetDate = now.add(Duration(days: daysUntilNextWeek));
        targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day,
            selectedHour, selectedMinute);
      }

      // Konversi ke TZDateTime
      final tz.TZDateTime tzTargetDate =
          tz.TZDateTime.from(targetDate, tz.local);

      targetDates.add(tzTargetDate);

      // Jadwalkan notifikasi
      await flutterLocalNotificationsPlugin.zonedSchedule(
        weekday,
        'Alarm Pengecekan Tanaman',
        'Waktunya memeriksa tanaman pada hari $day!',
        tzTargetDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> testNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'test_channel_id',
      'Test Notifications',
      channelDescription: 'Notifikasi untuk pengujian',
      importance: Importance.high,
      priority: Priority.high,
      channelShowBadge: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // ID notifikasi
      'Test Notification',
      'Notifikasi ini adalah tes apakah berjalan dengan baik!',
      notificationDetails,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi berhasil dikirim!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Fungsi untuk membatalkan semua notifikasi
  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Fungsi untuk menampilkan pop-up pengaturan alarm
  void showAlarmSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelectedDays = List.from(selectedDays);
        int tempSelectedHour = selectedHour;
        int tempSelectedMinute = selectedMinute;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Atur Jadwal Pengecekan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pilih Hari:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: days.map((day) {
                      bool isSelected = tempSelectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              tempSelectedDays.add(day);
                            } else {
                              tempSelectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Atur Waktu:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_up, size: 30),
                            onPressed: () {
                              setDialogState(() {
                                tempSelectedHour = (tempSelectedHour + 1) % 24;
                              });
                            },
                          ),
                          Text(
                            tempSelectedHour.toString().padLeft(2, '0'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down, size: 30),
                            onPressed: () {
                              setDialogState(() {
                                tempSelectedHour =
                                    (tempSelectedHour - 1 + 24) % 24;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        ':',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_up, size: 30),
                            onPressed: () {
                              setDialogState(() {
                                tempSelectedMinute =
                                    (tempSelectedMinute + 1) % 60;
                              });
                            },
                          ),
                          Text(
                            tempSelectedMinute.toString().padLeft(2, '0'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down, size: 30),
                            onPressed: () {
                              setDialogState(() {
                                tempSelectedMinute =
                                    (tempSelectedMinute - 1 + 60) % 60;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      selectedDays = tempSelectedDays;
                      selectedHour = tempSelectedHour;
                      selectedMinute = tempSelectedMinute;
                      if (selectedDays.isNotEmpty) {
                        isAlarmEnabled = true;
                      } else {
                        isAlarmEnabled = false;
                      }
                    });
                    if (isAlarmEnabled) {
                      await scheduleNotification();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Urutkan selectedDays berdasarkan urutan di daysOrder
    List<String> sortedDays = List.from(selectedDays);
    sortedDays.sort((a, b) => days.indexOf(a).compareTo(days.indexOf(b)));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _displayText,
          style: const TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: Expanded(
        child: Consumer<UserViewModel>(builder: (_, userViewModel, __) {
          if (userViewModel.status == Status.loading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF729762)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengecekan Lahan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.15,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2), // Efek bayangan
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_circle,
                      size: 50,
                    )),
                const SizedBox(height: 10),
                const Text(
                  'Hasil Panen',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                LineChartSample2(),
                const Text(
                  'Penghematan Pupuk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                LineChartSample2(),
                const Text(
                  'Jadwal Pengecekan Tanaman',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap:
                      showAlarmSettingsDialog, // Klik seluruh widget untuk mengatur waktu
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2), // Efek bayangan
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Bagian Waktu
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}', // Menampilkan waktu terpilih
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              sortedDays.isEmpty
                                  ? 'Tekan untuk memilih hari'
                                  : sortedDays.join(', '),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),

                        // Toggle Switch
                        Switch(
                          value: isAlarmEnabled,
                          onChanged: (value) async {
                            requestNotificationPermission();

                            if (selectedDays.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Pilih minimal satu hari untuk mengaktifkan alarm.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            setState(() {
                              isAlarmEnabled = value;
                            });
                            if (isAlarmEnabled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Alarm diatur pada ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} untuk hari ${selectedDays.isEmpty ? 'tidak ada hari' : selectedDays.join(', ')}'),
                                ),
                              );
                            }
                          },
                          activeColor: Colors.green, // Warna toggle aktif
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [Color(0xFF50E4FF), Color(0xFF2196F3)];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
