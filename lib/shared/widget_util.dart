part of 'shared.dart';

class WidgetUtil {
  static void showSnackBar(
      BuildContext context, String message, Color? snackBarColor) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: snackBarColor,
        ),
      );
    });
  }

  static MaterialPageRoute getRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
