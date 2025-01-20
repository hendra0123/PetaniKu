part of 'pages.dart';

class PredictionPage extends StatefulWidget {
  final Prediction prediction;

  const PredictionPage({super.key, required this.prediction});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final double initialZoom = AppConstant.defaultInitialZoom;

  late Prediction predictionData;
  late LatLng initialCenter;
  late CameraConstraint cameraConstraint;

  Color determineColorLevel(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFEB5600);
      case 2:
        return const Color(0xFFEBA000);
      case 3:
        return const Color(0xFF729762);
      case 4:
        return const Color(0xFF288500);
      case 0:
      default:
        return const Color(0xFF797979);
    }
  }

  String determineRiceCondition(List<int> riceLevels, String plantingType) {
    final averageLevel = riceLevels.reduce((val, e) => val + e) / riceLevels.length;

    String riceCondition;
    switch (averageLevel.round()) {
      case 1:
        riceCondition = "Padi anda sangat kekurangan nutrisi";
      case 2:
        riceCondition = "Padi anda kekurangan nutrisi";
      case 3:
        if (plantingType == "Direct Seeded") {
          riceCondition = "Padi anda memiliki nutrisi yang cukup";
        } else {
          riceCondition = "Padi anda memiliki nutrisi yang optimal";
        }
      case 4:
        riceCondition = "Padi anda memiliki nutrisi yang optimal";
      default:
        riceCondition = "Nutrisi padi tidak dapat diprediksi";
    }

    return riceCondition;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    predictionData = widget.prediction;
    initialCenter = GeoUtil.findPolygonCenter(predictionData.riceField!.polygon!);
    final cameraBounds = GeoUtil.findPolygonBounds(predictionData.riceField!.polygon!);
    cameraConstraint =
        CameraConstraint.containCenter(bounds: LatLngBounds(cameraBounds[0], cameraBounds[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pengecekan"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        children: [
          buildMap(),
          const SizedBox(height: 16),
          buildCurrentCondition(),
        ],
      ),
    );
  }

  Widget buildMap() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          maxZoom: initialZoom + 3,
          minZoom: initialZoom - 1,
          cameraConstraint: cameraConstraint,
        ),
        children: [
          AppConstant.openStreeMapTileLayer,
          ...buildRiceLeaves(),
          buildRiceField(),
        ],
      ),
    );
  }

  List<Widget> buildRiceLeaves() {
    final riceLeaves = predictionData.riceLeaves;
    if (riceLeaves == null || riceLeaves.isEmpty) {
      return [];
    }

    final polygons =
        riceLeaves.where((leaf) => leaf.polygon != null && leaf.polygon!.isNotEmpty).map((leaf) {
      return Polygon(
        points: leaf.polygon!,
        color: determineColorLevel(leaf.level ?? 0),
      );
    }).toList();

    final markers = riceLeaves
        .where((leaf) => leaf.points != null && leaf.points!.isNotEmpty)
        .expand((leaf) => leaf.points!)
        .map(
          (point) => Marker(
            point: point,
            child: const Icon(
              Icons.circle,
              size: 10,
            ),
          ),
        )
        .toList();

    return [PolygonLayer(polygons: polygons), MarkerLayer(markers: markers)];
  }

  Widget buildRiceField() {
    return PolygonLayer(
      polygons: [
        Polygon(
          borderStrokeWidth: 5,
          points: predictionData.riceField!.polygon!,
          borderColor: const Color(0xFF00AAFF),
          color: Colors.black.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget buildCurrentCondition() {
    final riceLevels =
        predictionData.riceLeaves!.where((e) => e.level != 0).map((e) => e.level!).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText(
          text: "Hasil Pengecekan",
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const SizedBox(height: 16),
        _buildText(
          text: determineRiceCondition(riceLevels, predictionData.plantingType!),
        ),
        const SizedBox(height: 8),
        _buildText(
          text: "Prediksi hasil panen :",
        ),
        _buildText(
          text: "${predictionData.yield!.round()} ton",
        ),
        const SizedBox(height: 8),
        _buildText(
          text: "Rekomendasi jumlah pupuk :",
        ),
        _buildText(
          text: "${predictionData.ureaRequired!.round()} kg",
        ),
        const SizedBox(height: 8),
        _buildText(
          text: "Tanggal pengecekan :",
        ),
        _buildText(
          text: predictionData.createdTime!.formatToCustomString(),
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Informasi Tanaman",
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Umur padi :",
        ),
        _buildText(
          text: "${predictionData.paddyAge} minggu",
        ),
        const SizedBox(height: 8),
        _buildText(
          text: "Musim saat pengecekan :",
        ),
        _buildText(
          text: '${predictionData.season}',
        ),
        const SizedBox(height: 8),
        _buildText(
          text: "Cara penanaman :",
        ),
        _buildText(
          text: '${predictionData.plantingType}',
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Foto Daun",
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: predictionData.imageUrls!.length,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(predictionData.imageUrls![index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Text _buildText({
    required String text,
    TextAlign? textAlign,
    FontWeight? fontWeight,
    double fontSize = 18,
    Color? color,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
