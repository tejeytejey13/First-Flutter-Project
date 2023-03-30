import 'package:flutter/material.dart';
import 'package:twitterproject/screen/profile.dart';

class List extends StatelessWidget {
  final IconData item;
  final String text;

  const List({
    super.key,
    required this.item,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: () {
               Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(),
                    ));
            },
            icon: Icon(
              item,
              color: Colors.black,
            ),
            label: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
