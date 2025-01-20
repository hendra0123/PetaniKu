part of 'shared.dart';

extension DateTimeFormatting on DateTime {
  String formatToCustomString() {
    DateFormat formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(this);
  }
}
