class Weather {
  final String cityName;
  final double temp;
  final double wind;
  final int humidity;
  final double feels_like;
  final int pressure;

  Weather(
      {required this.cityName,
      required this.temp,
      required this.wind,
      required this.humidity,
      required this.feels_like,
      required this.pressure});

  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'username': username,
  //       'password': password,
  //       'name': name,
  //       'email': email,
  //       'bio': bio,
  //       'location': location,
  //       'birthdate': birthdate,
  //       'age': age,
  //       'image': image,
  //     };

  static Weather fromJson(Map<String, dynamic> json) => Weather(
        cityName: json["name"],
        temp: json["main"]["temp"],
        wind: json["wind"]["speed"],
        pressure: json["main"]["pressure"],
        humidity: json["main"]["humidity"],
        feels_like: json["main"]["feels_like"],
      );
}
