import 'package:flutter/material.dart';

class PhotoHistoryPage extends StatelessWidget {
  final List<Map<String, String>> photoHistory = [
    {
      "date": "2024-12-01",
      "yield": "85%",
      "condition": "Baik",
      "imagePath": "assets/images/pdi1.jpeg"
    },
    {
      "date": "2024-12-02",
      "yield": "90%",
      "condition": "Kurang Baik",
      "imagePath": "assets/images/pdi2.jpeg"
    },
    {
      "date": "2024-12-03",
      "yield": "78%",
      "condition": "Sangat Baik",
      "imagePath": "assets/images/pdi3.jpeg"
    },
  ];

  PhotoHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("History"),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: photoHistory.length,
        itemBuilder: (context, index) {
          final historyItem = photoHistory[index];
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
                    image: AssetImage(historyItem["imagePath"]!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                "Tanggal: ${historyItem['date']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tingkat Yield: ${historyItem['yield']}"),
                  Text("Kondisi Padi: ${historyItem['condition']}"),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  // Navigasi ke detail halaman jika diperlukan
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Lihat detail untuk foto pada ${historyItem['date']}"),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
