class User {
  String name;
  String role;
  DateTime exp;

  User({required this.name, required this.role, required this.exp});

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        role: json["role"],
        exp: DateTime.fromMillisecondsSinceEpoch(json["exp"] * 1000,
            isUtc: false),
      );
}
