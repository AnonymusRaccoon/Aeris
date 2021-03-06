import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  ///Leading widget (like an icon) on the left
  final Widget leading;

  ///Title, displayed at the center
  final String title;

  ///Widget on the right of the card
  final Widget trailing;

  const ServiceCard(
      {Key? key,
      required this.leading,
      required this.title,
      required this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 15, right: 6),
        child: Row(
          children: [
            Expanded(child: leading, flex: 2),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15
                ),
                textAlign: TextAlign.center,
              ),
              flex: 8
            ),
            Expanded(child: trailing, flex: 2),
          ],
        ),
      )
    );
  }
}
