import 'package:petaniku/pages/camera_page.dart';
import 'package:petaniku/pages/dashboard_page.dart';
import 'package:petaniku/pages/history_page.dart';
import 'package:petaniku/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petaniku/pages/tes.dart';
import 'pages/signup_page.dart';
import 'package:camera/camera.dart';

// Global variable to store available cameras
late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cameras
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetaniKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/signup",
      routes: {
        "/dashboard": (context) => const MainNavigationPage(),
        "/signup": (context) => SignUpPage(),
        "/login": (context) => LoginPage(),
        "/camera": (context) => CameraPage(
              camera: cameras.first,
            ),
        "/history": (context) => PhotoHistoryPage(),
        "/tes": (context) => tes()
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    const DashboardPage(),
    CameraPage(camera: cameras.first),
    PhotoHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.camera_enhance),
            icon: Icon(Icons.camera_enhance_outlined),
            label: 'Kamera',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.history_toggle_off),
            icon: Icon(Icons.history_toggle_off_outlined),
            label: 'Riwayat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
