import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription camera;

  const CameraPage({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;

  // Controllers for form fields
  final TextEditingController _ageController = TextEditingController();

  // Dropdown values
  String? _selectedSeason;
  String? _selectedPlantingMethod;
  String? _selectedSeedType;

  final List<String> _seasons = ['Hujan', 'Kemarau'];
  final List<String> _plantingMethods = [
    'Semai/Transplantasi',
    'Tanam Benih Langsung (TABELA)'
  ];
  final List<String> _seedTypes = ['Padi Inpari'];

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kamera",
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: _capturedImage == null
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: "Umur Padi (dalam bulan)",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedSeason,
                          decoration: const InputDecoration(
                            labelText: "Musim",
                            border: OutlineInputBorder(),
                          ),
                          items: _seasons
                              .map((season) => DropdownMenuItem<String>(
                                    value: season,
                                    child: Text(season),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSeason = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedPlantingMethod,
                          decoration: const InputDecoration(
                            labelText: "Cara Penanaman",
                            border: OutlineInputBorder(),
                          ),
                          items: _plantingMethods
                              .map((method) => DropdownMenuItem<String>(
                                    value: method,
                                    child: Text(method),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlantingMethod = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedSeedType,
                          decoration: const InputDecoration(
                            labelText: "Jenis Bibit",
                            border: OutlineInputBorder(),
                          ),
                          items: _seedTypes
                              .map((seed) => DropdownMenuItem<String>(
                                    value: seed,
                                    child: Text(seed),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSeedType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () => setState(() => _capturedImage = null),
                        child: const Text("Ulang",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          if (_validateInputs()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Data dikirim!")),
                            );
                          }
                        },
                        child: const Text(
                          "Cek Tanaman",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
      floatingActionButton: _capturedImage == null
          ? FloatingActionButton.extended(
              backgroundColor: Colors.green,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil Foto"),
              onPressed: () async {
                try {
                  await _initializeControllerFuture;
                  final image = await _cameraController.takePicture();
                  setState(() {
                    _capturedImage = image;
                  });
                } catch (e) {
                  print(e);
                }
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  bool _validateInputs() {
    if (_ageController.text.isEmpty ||
        _selectedSeason == null ||
        _selectedPlantingMethod == null ||
        _selectedSeedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua field!")),
      );
      return false;
    }
    return true;
  }
}
