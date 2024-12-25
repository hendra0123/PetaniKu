part of 'shared.dart';

class UserConstant {
  // TODO: REMOVE ALL AFTER TESTING
  // static RiceField? riceField = null;
  static RiceField? riceField = RiceField(area: 2, createdTime: DateTime.now(), coordinates: const [
    LatLng(-5.149326, 119.394834),
    LatLng(-5.149333, 119.395184),
    LatLng(-5.149041, 119.395200),
    LatLng(-5.149052, 119.395396),
    LatLng(-5.149565, 119.395370),
    LatLng(-5.149569, 119.395431),
    LatLng(-5.149711, 119.395425),
    LatLng(-5.149687, 119.394879),
    LatLng(-5.149572, 119.394823),
    LatLng(-5.149326, 119.394834),
  ]);

  static void setRiceField(RiceField? newRiceField) {
    riceField = newRiceField;
  }

  static int index = 0;

  // static List<LatLng> tester = const [
  //   LatLng(-5.149326, 119.394834),
  //   LatLng(-5.149333, 119.395184),
  //   LatLng(-5.149041, 119.395200),
  //   LatLng(-5.149052, 119.395396),
  //   LatLng(-5.149565, 119.395370),
  //   LatLng(-5.149569, 119.395431),
  //   LatLng(-5.149711, 119.395425),
  //   LatLng(-5.149687, 119.394879),
  //   LatLng(-5.149572, 119.394823),
  //   LatLng(-5.149326, 119.394834),
  // ];
  static List<LatLng> tester = const [
    LatLng(-5.14960, 119.39500),
    LatLng(-5.14960, 119.39600),
    LatLng(-5.14900, 119.39600),
    LatLng(-5.14900, 119.39500),
    LatLng(-5.14960, 119.39500),
  ];

  static LatLng getCoord() {
    if (index == tester.length) return tester[index - 1];
    LatLng coord = tester[index];
    index++;
    return coord;
  }
}
