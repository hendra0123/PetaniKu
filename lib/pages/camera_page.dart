import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:petaniku/pages/formplant_page.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription camera;

  const CameraPage({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  List<XFile> _capturedImages = [];
  bool _isInCameraMode = true;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _cameraController.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInfoDialog());
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Informasi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Silahkan mengambil hingga 10 foto tanaman Anda untuk analisis lebih lanjut.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePicture() async {
    // kekx gak perlu karna nda adamih tombol +
    if (_capturedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anda hanya dapat mengambil maksimal 10 foto."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      setState(() {
        _capturedImages.add(image);
        _isInCameraMode = false; // Kembali ke tampilan grid setelah foto
      });
    } catch (e) {
      print(e);
    }
  }

  void _enterCameraMode() {
    if (_capturedImages.length < 10) {
      setState(() {
        _isInCameraMode = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anda hanya dapat mengambil maksimal 10 foto."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewImage(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Kamera"),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: _isInCameraMode
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_cameraController),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: FloatingActionButton.extended(
                            backgroundColor: Colors.green,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Ambil Foto"),
                            onPressed: _takePicture,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _capturedImages.length < 10
                        ? _capturedImages.length + 1
                        : _capturedImages.length,
                    itemBuilder: (context, index) {
                      if (index < _capturedImages.length) {
                        return GestureDetector(
                          onTap: () => _viewImage(_capturedImages[index].path),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(
                              File(_capturedImages[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: _enterCameraMode,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.green, width: 2)),
                            child: const Center(
                              child: Icon(Icons.add,
                                  color: Colors.green, size: 50),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final imageFiles = _capturedImages
                          .map((xfile) => File(xfile.path))
                          .toList();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FormPlant(images: imageFiles),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload, color: Colors.white),
                    label: const Text(
                      "Kirim Foto",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const FullScreenImageView({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
