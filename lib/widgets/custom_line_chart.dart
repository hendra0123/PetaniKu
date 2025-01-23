part of 'widgets.dart';

class CustomLineChart extends StatefulWidget {
  final List<double> mainData;
  final List<DateTime> dataDates;
  const CustomLineChart({super.key, required this.mainData, required this.dataDates});

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  final List<Color> gradientColors = [const Color(0xFF729762), const Color(0xFF288500)];
  final double intervalCount = 11;

  List<FlSpot> spotsData = const [];

  late num maxY;
  late List<num> yLabels;
  late Map<int, String> xLabels;

  void _processData() {
    List<double> mainData = widget.mainData;
    List<DateTime> dataDates = widget.dataDates;

    if (mainData.length == 1) {
      mainData.insert(0, 0);
    }
    if (dataDates.length == 1) {
      dataDates.insert(0, dataDates.first.subtract(const Duration(days: 1)));
    }

    // Y-axis labels
    maxY = _closestMultipleOf5(mainData.reduce((a, b) => a > b ? a : b));
    yLabels = [
      (maxY * 0.2).ceil(),
      (maxY * 0.4).ceil(),
      (maxY * 0.6).ceil(),
      (maxY * 0.8).ceil(),
      maxY,
    ];

    // X-axis labels
    final DateTime minDate = dataDates.first;
    final DateTime maxDate = dataDates.last;
    final double totalDays = maxDate.difference(minDate).inDays.toDouble();

    xLabels = {
      1: _getDateLabel(minDate, maxDate, 1, totalDays),
      4: _getDateLabel(minDate, maxDate, 4, totalDays),
      7: _getDateLabel(minDate, maxDate, 7, totalDays),
      10: _getDateLabel(minDate, maxDate, 10, totalDays),
    };
    _removeDuplicates(xLabels);

    // Spots Data
    spotsData = List.generate(
      dataDates.length,
      (index) {
        final double normalizedX =
            dataDates[index].difference(minDate).inDays.toDouble() / totalDays * intervalCount;
        return FlSpot(normalizedX, mainData[index]);
      },
    );
  }

  num _closestMultipleOf5(num value) {
    return (value / 5).ceil() * 5;
  }

  String _getDateLabel(DateTime minDate, DateTime maxDate, int position, double totalDays) {
    final double daysForPosition = (position / intervalCount) * totalDays;
    final DateTime labelDate = minDate.add(Duration(days: daysForPosition.round()));
    return "${labelDate.day} ${_monthName(labelDate.month)}";
  }

  String _monthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }

  void _removeDuplicates(Map<int, String> map) {
    final seenValues = <String>{};
    final keysToRemove = <int>[];

    map.forEach((key, value) {
      if (!seenValues.add(value)) {
        keysToRemove.add(key); // Track duplicate keys
      }
    });

    // Remove keys with duplicate values
    for (final key in keysToRemove) {
      map.remove(key);
    }
  }

  final style = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LineChart(mainData()),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (xLabels.containsKey(value.ceil())) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(xLabels[value.toInt()]!, style: style),
      );
    }
    return const SizedBox.shrink();
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (yLabels.contains(value.ceil())) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Text("${value.ceil()}", textAlign: TextAlign.right, style: style),
      );
    }
    return const SizedBox.shrink();
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black),
      ),
      minX: 0,
      maxX: intervalCount,
      minY: 0,
      maxY: yLabels.last.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spotsData,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
