import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:petaniku/const.dart';

class FormPlant extends StatefulWidget {
  final List<File> images;

  const FormPlant({Key? key, required this.images}) : super(key: key);

  @override
  State<FormPlant> createState() => _FormPageState();
}

class _FormPageState extends State<FormPlant> {
  String? selectedSeason;
  String? selectedPlantingType;
  final TextEditingController paddyAge = TextEditingController();
  String url = "https://dmlj3k21-5000.asse.devtunnels.ms/user/predictions";

  final List<String> seasonOption = ['Musim Kemarau', 'Musim Hujan'];
  final List<String> plantingTypeOption = [
    'Pemindahan Bibit (Semai)',
    'Tabur Benih Langsung (Tabela)'
  ];

  @override
  void dispose() {
    paddyAge.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (selectedSeason == null ||
        selectedPlantingType == null ||
        paddyAge.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua field sebelum mengirim."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      converter();
      kirimData();

      //pengetesan doang
      selectedSeason = null;
      selectedPlantingType = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil dikirim!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Tampilkan data form dan gambar
    print("Cuaca: $selectedSeason");
    print("Tipe Penanaman: $selectedPlantingType");
    print("Umur Padi: ${paddyAge.text}");
    print("Gambar yang dikirim: ${widget.images.length} gambar");
  }

  void converter() {
    if (selectedSeason == "Musim Kemarau") {
      selectedSeason = "Dry";
    } else if (selectedSeason == "Musim Hujan") {
      selectedSeason = "Wet";
    }

    if (selectedPlantingType == "Pemindahan Bibit (Semai)") {
      selectedPlantingType = "Transplanted";
    } else if (selectedPlantingType == "Tabur Benih Langsung (Tabela)") {
      selectedPlantingType = "Direct Seeded";
    }
  }

  Future<void> kirimData() async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      print("Token: ${Const.token}");

      request.headers['Authorization'] =
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiaGEwY1F5S3pnMm83SEZOclVZazQiLCJleHAiOjE3MzYyMTIyODEsImlhdCI6MTczNjEyNTg4MX0.VuX9XWAf1TRxC-SVA-rRkYPNlAGxJUUPti8vF_kwi4Q';

      request.fields['payload'] =
          '{  "season": "{$selectedSeason}",  "planting_type": "{$selectedPlantingType}",  "paddy_age": {$paddyAge},  "coordinates": [    {"latitude": -7.797068, "longitude": 110.370529},    {"latitude": -7.798068, "longitude": 110.371529}  ]}';
      for (int i = 0; i < widget.images.length; i++) {
        final file = await http.MultipartFile.fromPath(
          'images', // Nama field di server
          widget.images[i].path,
        );
        request.files.add(file);
      }
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final decodedData = json.decode(responseData.body);
//ato mo pake ini?
      // for (int i = 0; i < widget.images.length; i++) {
      //   request.files.add(http.MultipartFile.fromBytes(
      //     'images',
      //     File(widget.images[i].path).readAsBytesSync(),
      //     filename: widget.images[i].path.split('/').last,
      //   ));
      // }

      // Kirim request

      if (response.statusCode == 200) {
        print("Berhasil: $decodedData");
      } else {
        print("Gagal mengirim data: ${response.statusCode}");
        print(json.decode(responseData.body)['pesan']);
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Data Tanaman"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cuaca:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButtonFormField<String>(
                value: selectedSeason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: seasonOption
                    .map((weather) => DropdownMenuItem(
                          value: weather,
                          child: Text(weather),
                        ))
                    .toList(),
                hint: Align(
                  alignment: Alignment.center,
                  child: Text("Pilih Cuaca"),
                ),
                onChanged: (value) => setState(() {
                  selectedSeason = value;
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                "Tipe Penanaman:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButtonFormField<String>(
                value: selectedPlantingType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pilih Tipe Penanaman',
                ),
                items: plantingTypeOption
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                hint: Align(
                  alignment: Alignment.center,
                  child: Text("Pilih Tipe Penanaman"),
                ),
                onChanged: (value) => setState(() {
                  selectedPlantingType = value;
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                "Umur Padi (Hari):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: paddyAge,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan umur padi',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text(
                "Gambar yang Dikirim:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Image.file(
                        widget.images[index],
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Kirim Data",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
