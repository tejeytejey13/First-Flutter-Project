import 'package:flutter/material.dart';
import 'package:twitterproject/services/alertdialogs.dart';

class List2 extends StatelessWidget {
  final IconData item;
  final String text;

  const List2({
    super.key,
    required this.item,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'AlertDialog';
    bool tappedYes = false;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: () async {
              final action = await AlertDialogs.yesCancelDialog(
                  context, 'Logout', 'Are you sure you want to Logout?');
              if (action == DialogsAction.yes) {
                setState(() => tappedYes = true);
              } else {
                setState(() => tappedYes = false);
              }
            },
            icon: Icon(
              item,
              color: Colors.redAccent,
            ),
            label: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void setState(bool Function() param0) {}
}
