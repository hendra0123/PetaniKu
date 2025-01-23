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

  String determineRiceCondition(double percentage) {
    String riceCondition;
    if (percentage <= 0.3) {
      riceCondition = "Sangat buruk";
    } else if (percentage > 0.3 && percentage <= 0.6) {
      riceCondition = "Buruk";
    } else if (percentage > 0.6 && percentage <= 0.8) {
      riceCondition = "Baik";
    } else {
      riceCondition = "Optimal";
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
        padding: const EdgeInsets.all(16),
        children: [
          buildMap(),
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
        predictionData.riceLeaves!.where((e) => e.level != null && e.level != 0).map((e) {
      if ((predictionData.plantingType ?? '') == "Direct Seeded" && e.level! == 3) {
        return 4;
      }
      return e.level!;
    }).toList();
    final levelPercentage = riceLevels.reduce((val, e) => val + e) / (riceLevels.length * 4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildText(
          text: "Hasil Pengecekan",
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoRectangleWidget(
              percentage: levelPercentage,
              header: "Nutrisi Padi",
              footer: determineRiceCondition(levelPercentage),
              backgroundColor: Colors.white,
              borderColor: const Color(0xFF729762),
            ),
            InfoRectangleWidget(
              percentage: predictionData.yield! / predictionData.riceField!.maxYield!,
              header: "Prediksi Panen",
              footer: "${predictionData.yield!.ceil()} ton",
              backgroundColor: Colors.white,
              borderColor: const Color(0xFF729762),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Rekomendasi pupuk : ${predictionData.ureaRequired!.round()} kg",
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Tanggal : ${predictionData.createdTime!.formatToCustomString()}",
        ),
        const SizedBox(height: 32),
        _buildText(
          text: "Informasi Tanaman",
          fontSize: 24,
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Umur padi : ${predictionData.paddyAge} minggu",
        ),
        const SizedBox(height: 16),
        _buildText(
          text: "Musim : ${predictionData.season == "Wet" ? "Hujan" : "Kemarau"}",
        ),
        const SizedBox(height: 16),
        _buildText(
          text:
              "Cara penanaman : ${predictionData.plantingType == "Direct Seeded" ? "Tabela" : "Semai"}",
        ),
        const SizedBox(height: 32),
        _buildText(
          text: "Foto Daun",
          fontSize: 24,
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
    FontWeight fontWeight = FontWeight.bold,
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
