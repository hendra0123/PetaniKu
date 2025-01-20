part of 'pages.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late PredictionViewModel predictionViewModel;
  late HistoryViewModel historyViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    historyViewModel = Provider.of<HistoryViewModel>(context);
    predictionViewModel = Provider.of<PredictionViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (historyViewModel.status != Status.error) historyViewModel.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Riwayat Pengecekan"),
      ),
      body: Builder(builder: (context) {
        if (historyViewModel.status == Status.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF729762)));
        }

        if (historyViewModel.status == Status.error) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Terjadi kesalahan saat proses pengambilan data",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              MainButton(
                onPressed: () => historyViewModel.getHistory(),
                text: 'Coba Lagi',
              ),
            ],
          );
        }

        if (!historyViewModel.isHistoryPresent) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Riwayat pengecekan padi anda akan ditampilkan di sini",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        final histoyData = historyViewModel.history;
        return Stack(
          children: [
            buildHistoryCards(histoyData!),
            buildLoadingOverlay(),
          ],
        );
      }),
    );
  }

  Widget buildHistoryCards(List<History> histoyData) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      itemCount: histoyData.length,
      itemBuilder: (context, index) {
        final data = histoyData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(data.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              data.createdTime!.formatToCustomString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prediksi Panen:\n${data.yield!.round()} ton"),
                Text("Kebutuhan Pupuk:\n${data.ureaRequired!.round()} kg urea"),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                predictionViewModel.getPrediction(data.predictionId!);
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildLoadingOverlay() {
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
          Navigator.of(context).push(WidgetUtil.getRoute(PredictionPage(
            prediction: predictionViewModel.prediction!,
          )));
        });
      }

      return const SizedBox.shrink();
    });
  }
}
