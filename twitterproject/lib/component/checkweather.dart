import 'package:flutter/material.dart';
import 'package:twitterproject/database/weather.dart';
import 'package:twitterproject/services/weather_api.dart';
import 'package:twitterproject/views/addinformation.dart';
import 'package:twitterproject/views/currentweather.dart';

class CheckWeather extends StatefulWidget {
  const CheckWeather({super.key});

  @override
  State<CheckWeather> createState() => _CheckWeatherState();
}

class _CheckWeatherState extends State<CheckWeather> {
  WeatherApi client = WeatherApi();
  Weather? data;

  Future<void> getData() async {
    data = await client.getCurrentWeather("Philippines");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Weather'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: currentWeather(
                    Icons.wb_sunny_rounded,
                    "${data!.temp}",
                    "${data!.cityName}",
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 20.0, color: Colors.grey.shade300),
                ),
                Divider(),
                SizedBox(
                  height: 15.0,
                ),
                addInformation("${data!.wind}", "${data!.humidity}",
                    "${data!.pressure}", "${data!.feels_like}")
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container();
        },
      ),
    );
  }
}
