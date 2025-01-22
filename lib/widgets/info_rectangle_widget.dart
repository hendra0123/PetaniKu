part of 'widgets.dart';

class InfoRectangleWidget extends StatelessWidget {
  final double percentage;
  final String header;
  final String footer;
  final Color backgroundColor;
  final Color borderColor;

  const InfoRectangleWidget({
    super.key,
    required this.percentage,
    required this.header,
    required this.footer,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 8.0,
            animation: true,
            percent: percentage,
            header: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                header,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            center: Text(
              '${(percentage * 100).ceil()}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            footer: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                footer,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: const Color(0xFF729762),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
