import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petaniku/pages/pages.dart';
import 'package:petaniku/view_model/view_model.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

// Global variable to store available cameras
late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize cameras
  cameras = await availableCameras();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetaniKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF729762),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: "/dashboard",
      routes: {
        "/dashboard": (context) => const MainNavigationPage(),
        "/signup": (context) => const SignUpPage(),
        "/login": (context) => const LoginPage(),
        "/camera": (context) => CameraPage(
              camera: cameras.first,
            ),
        "/history": (context) => PhotoHistoryPage(),
        "/map": (context) => const MapPage(),
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
          ],
        ),
        child: BottomNavigationBar(
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
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF729762),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
