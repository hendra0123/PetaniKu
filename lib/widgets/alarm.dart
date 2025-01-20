part of 'widgets.dart';

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  List<String> selectedDays = [];
  List<DateTime> targetDates = [];
  int selectedHour = 9;
  int selectedMinute = 0;
  int indexTargetDates = 0;
  bool isAlarmEnabled = false;

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
          targetDate = now.add(const Duration(days: 7));
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
  }

  @override
  Widget build(BuildContext context) {
    // Urutkan selectedDays berdasarkan urutan di daysOrder
    List<String> sortedDays = List.from(selectedDays);
    sortedDays.sort((a, b) => days.indexOf(a).compareTo(days.indexOf(b)));
    return GestureDetector(
      onTap:
          showAlarmSettingsDialog, // Klik seluruh widget untuk mengatur waktu
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }
}
