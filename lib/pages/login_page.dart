// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get_phone_number/get_phone_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petaniku/repository/repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool? isChecked = false;
  var message = 'Please try to functions below.';
  String? simNumber;
  UserRepository userRepository = UserRepository();

  Future<void> requestPhoneCallPermission() async {
    final status = await Permission.phone.status;

    if (status.isDenied || status.isRestricted) {
      await Permission.phone.request();
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return;
    }
    if (await Permission.phone.isGranted) {
      try {
        String result = await GetPhoneNumber().getPhoneNumber();
        setState(() {
          simNumber = result;
        });
      } catch (e) {
        setState(() => message = e.toString());
      }
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await requestPhoneCallPermission();
      final enteredPhoneNumber = _phoneController.text.trim();

      if (simNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nomor telepon SIM tidak tersedia.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (enteredPhoneNumber != simNumber) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nomor tidak sesuai dengan nomor SIM. Harap periksa kembali nomor Anda.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      fetchLogin();
    }
  }

  Future<void> fetchLogin() async {
    try {
      String message = await userRepository.login(_phoneController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonDecode(message))),
      );

      Navigator.of(context).pushNamedAndRemoveUntil("/dashboard", (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonDecode(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
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
              "Aplikasi membutuhkan izin untuk mengakses nomor telepon Anda agar dapat berfungsi dengan baik. "),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text('Masuk',
                style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(3, 23, 73, 1))),
            CarouselSlider(
              items: [
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/pdi3.jpeg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/pdi2.jpeg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/pdi1.jpeg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              options: CarouselOptions(
                height: 180.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
            ),
            const SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    cursorColor: const Color.fromRGBO(8, 35, 103, 1),
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      labelStyle: TextStyle(color: Color.fromRGBO(8, 35, 103, 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color.fromRGBO(8, 35, 103, 1), width: 1.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color.fromRGBO(3, 23, 73, 1), width: 1.5)),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon masukkan nomor telepon anda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.06,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                          backgroundColor:
                              const WidgetStatePropertyAll(Color.fromRGBO(3, 23, 73, 1))),
                      onPressed: _validateAndSubmit,
                      child: const Text(
                        'Masuk',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Row(children: <Widget>[
                    Expanded(child: Divider()),
                    SizedBox(
                      width: 16,
                    ),
                    Text("atau"),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.06,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: const WidgetStatePropertyAll(Colors.white),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: const BorderSide(color: Color.fromRGBO(3, 23, 73, 1))))),
                      onPressed: () {
                        setState(() {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil("/signup", ((route) => false));
                        });
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(color: Color.fromRGBO(3, 23, 73, 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
