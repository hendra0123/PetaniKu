import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<String> selectedDays = [];
  int selectedHour = 9;
  int selectedMinute = 0;
  bool isAlarmEnabled = false;
  DateTime? nextCheckTime; // Waktu pengecekan berikutnya
  late Timer _timer;
  Duration remainingTime = Duration.zero;
  List<DateTime> targetDates = [];
  int indexTargetDates = 0;
  var message = 'Please try to functions below.';

  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void dispose() {
    _timer.cancel(); // Menghentikan timer ketika halaman ditutup
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (nextCheckTime != null) {
        setState(() {
          remainingTime = nextCheckTime!.difference(DateTime.now());
          if (remainingTime.isNegative) {
            remainingTime = Duration.zero;
            _timer.cancel();
          }
        });
      }
    });
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted) {
      await Permission.notification.request();
    }
    print('Notification Permission: ${status.isGranted}');

    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return;
    }

    if (status.isGranted) {
      return;
    } else {
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
  void initState() {
    super.initState();
    initializeNotifications();
    if (targetDates.isNotEmpty) {
      nextCheckTime = targetDates[indexTargetDates];
    }
    _startCountdown();
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

  void _handleCheckReminder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengecekan Tanaman'),
          content:
              const Text('Apakah Anda sudah melakukan pengecekan tanaman?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  indexTargetDates++;
                  nextCheckTime = DateTime.now()
                      .add(Duration(days: targetDates[indexTargetDates].day));
                  remainingTime = nextCheckTime!.difference(DateTime.now());
                  _startCountdown();
                });
              },
              child: const Text('Sudah'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  nextCheckTime = DateTime.now().add(Duration(minutes: 5));
                  remainingTime = nextCheckTime!.difference(DateTime.now());
                  _startCountdown();
                });
              },
              child: const Text('Belum'),
            ),
          ],
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
        title: const Text('Beranda'),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   width: double.infinity,
              //   padding: EdgeInsets.all(16.0),
              //   margin: EdgeInsets.all(8.0),
              //   decoration: BoxDecoration(
              //     color: Colors.lightBlue.shade100,
              //     borderRadius: BorderRadius.circular(12.0),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 8.0,
              //         offset: Offset(0, 4),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Reminder Pengecekan Tanaman',
              //         style: TextStyle(
              //           fontSize: 20.0,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.blueAccent,
              //         ),
              //       ),
              //       SizedBox(height: 8.0),
              //       Text(
              //         remainingTime > Duration.zero
              //             ? 'Sisa waktu: ${_formatDuration(remainingTime)}'
              //             : 'Waktunya melakukan pengecekan ulang!',
              //         style: TextStyle(
              //           fontSize: 16.0,
              //           color: Colors.black87,
              //         ),
              //       ),
              //       if (remainingTime == Duration.zero)
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.end,
              //           children: [
              //             ElevatedButton(
              //               onPressed: _handleCheckReminder,
              //               child: const Text('Cek Tanaman'),
              //             ),
              //           ],
              //         ),
              //     ],
              //   ),
              // ),
              const Text(
                'Pengecekan Lahan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.all(8),
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
                child: GestureDetector(
                  onTap: () {
                    // Tambahkan logika yang ingin dijalankan saat container di-tap
                    print('Container di-tap');
                  },
                  child: Container(
                      width: 300,
                      height: 100,
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: Icon(Icons.add_circle,
                          size: 50, color: Colors.white)),
                ),
              ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                ? 'Tidak ada hari yang dipilih'
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
        ),
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
