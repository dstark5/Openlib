import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  const TitleText(this.text, {super.key});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 40,
          // fontWeight: FontWeight.w500,
          // color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}
