part of 'widgets.dart';

class MainButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool isExpanded;
  final Color buttonColor;
  final double buttonWidth;
  const MainButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.isExpanded = false,
      this.buttonColor = const Color(0xFF729762),
      this.buttonWidth = 0});

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return Expanded(child: buildButton());
    } else {
      return buildButton();
    }
  }

  Widget buildButton() {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(buttonWidth, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: buttonColor,
          disabledBackgroundColor: Colors.grey,
        ),
        child: Text(text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )));
  }
}
