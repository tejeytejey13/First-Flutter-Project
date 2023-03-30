class Users {
  final String id;
  final String name;
  final String username;
  final String password;
  final String email;
  final String bio;
  final String location;
  final String birthdate;
  final String age;
  final String image;

  Users(
      {required this.id,
      required this.name,
      required this.username,
      required this.password,
      required this.email,
      required this.bio,
      required this.location,
      required this.birthdate,
      required this.age,
      required this.image,});

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'name': name,
        'email': email,
        'bio': bio,
        'location': location,
        'birthdate': birthdate,
        'age': age,
        'image': image,
      };

  static Users fromJson(Map<String, dynamic> json) => Users(
        id: json['id'],
        name: json['name'],
        username: json['username'],
        password: json['password'],
        email: json['email'],
        birthdate: json['birthdate'],
        age: json['age'],
        bio: json['bio'],
        location: json['location'],
        image: json['image'],
      );
}
