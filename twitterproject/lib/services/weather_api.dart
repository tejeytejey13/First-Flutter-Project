import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:twitterproject/database/weather.dart';

class WeatherApi {
  Future<Weather>? getCurrentWeather(String? location) async {
    var endpoint = Uri.parse(
      "http://api.openweathermap.org/data/2.5/weather?q=$location&APPID=56b64aebbe5320ee93d046c1c09d329b&units=metric",
    );
    var response = await http.get(endpoint);
    var body = jsonDecode(response.body);
    Weather weather = Weather.fromJson(body);
    print(
      Weather.fromJson(body).cityName,
    );
    return Weather.fromJson(body);
  }
}
