import 'package:flutter/material.dart';

class ShadowButton extends StatelessWidget {
  final IconData icon;
  // ignore: prefer_typing_uninitialized_variables
  final onTap;
  final Color color;

  const ShadowButton({
    Key? key,
    required this.icon,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
