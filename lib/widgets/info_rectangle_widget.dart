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
    this.borderColor = const Color(0xFF729762),
  });

  Color determineCircularColor(double percentage) {
    Color circularColor;
    if (percentage <= 0.3) {
      circularColor = const Color(0xFFEB2F00);
    } else if (percentage > 0.3 && percentage <= 0.6) {
      circularColor = const Color(0xFFEBA000);
    } else if (percentage > 0.6 && percentage <= 0.8) {
      circularColor = const Color(0xFFa7cd95);
    } else {
      circularColor = const Color(0xFF729762);
    }
    return circularColor;
  }

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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            center: Text(
              '${(percentage * 100).ceil()}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            progressColor: determineCircularColor(percentage),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
