import 'package:flutter/material.dart';

Widget currentWeather(IconData icon, String temp, String location) {
  return Column(
    children: [
      Icon(
        icon,
        color: Colors.amber,
        size: 64.0,
      ),
      SizedBox(
        height: 5,
      ),
      Text(
        "$temp",
        style: TextStyle(fontSize: 36.0),
      ),
      SizedBox(
        height: 5,
      ),
      Text(
        "$location",
        style: TextStyle(fontSize: 18.0, color: Colors.grey.shade500),
      ),
    ],
  );
}
