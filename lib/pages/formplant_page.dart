part of 'pages.dart';

class FormPlant extends StatefulWidget {
  final List<File> images;
  final List<LatLng> points;

  const FormPlant({super.key, required this.images, required this.points});

  @override
  State<FormPlant> createState() => _FormPageState();
}

class _FormPageState extends State<FormPlant> {
  final TextEditingController paddyAgeController = TextEditingController();
  final List<String> seasonOption = ['Musim Kemarau', 'Musim Hujan'];
  final List<String> plantingTypeOption = [
    'Pemindahan Bibit (Semai)',
    'Tabur Benih Langsung (Tabela)'
  ];

  String? selectedSeason;
  String? selectedPlantingType;
  String convertedSeason = '';
  String convertedPlantingType = '';
  int paddyAge = 0;

  late PredictionViewModel predictionViewModel;

  void _submitForm() {
    if (selectedSeason == null ||
        selectedPlantingType == null ||
        num.tryParse(paddyAgeController.text) == null) {
      WidgetUtil.showSnackBar(context, "Mohon lengkapi semua data sebelum mengirim.", Colors.red);
    } else if (num.parse(paddyAgeController.text) <= 0 || num.parse(paddyAgeController.text) > 16) {
      WidgetUtil.showSnackBar(
          context, "Umur padi hanya boleh dalam rentang 1 sampai 16 minggu", Colors.red);
    } else {
      converter();
      predictionViewModel.postPrediction(
          convertedSeason, convertedPlantingType, paddyAge, widget.images, widget.points);
    }
  }

  void converter() {
    if (selectedSeason == "Musim Kemarau") {
      convertedSeason = "Dry";
    } else if (selectedSeason == "Musim Hujan") {
      convertedSeason = "Wet";
    }

    if (selectedPlantingType == "Pemindahan Bibit (Semai)") {
      convertedPlantingType = "Transplanted";
    } else if (selectedPlantingType == "Tabur Benih Langsung (Tabela)") {
      convertedPlantingType = "Direct Seeded";
    }

    paddyAge = num.parse(paddyAgeController.text).toInt();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    predictionViewModel = Provider.of<PredictionViewModel>(context);
  }

  @override
  void dispose() {
    paddyAgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Data Tanaman"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
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
                    hint: const Align(
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
                    hint: const Align(
                      alignment: Alignment.center,
                      child: Text("Pilih Tipe Penanaman"),
                    ),
                    onChanged: (value) => setState(() {
                      selectedPlantingType = value;
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Umur Padi (Minggu):",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextFormField(
                    controller: paddyAgeController,
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
                    child: MainButton(
                      onPressed: _submitForm,
                      text: 'Kirim Data',
                      buttonWidth: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Builder(builder: (context) {
      if (predictionViewModel.status == Status.loading) {
        return Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF729762)),
          ),
        );
      }

      if (predictionViewModel.status == Status.error) {
        WidgetUtil.showSnackBar(context,
            predictionViewModel.message ?? "Terjadi kesalahan saat mengirim data", Colors.red);
      }

      if (predictionViewModel.status == Status.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop(predictionViewModel.prediction);
        });
      }

      return const SizedBox.shrink();
    });
  }
}
