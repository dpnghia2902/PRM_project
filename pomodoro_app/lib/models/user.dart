class User {

  final String id;
  final String fullName;
  final String email;
  final String gender;
  final String avatar;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.avatar,
  });

  factory User.fromJson(Map<String,dynamic> json){

    return User(
      id: json["_id"],
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      gender: json["gender"] ?? "",
      avatar: json["avatar"] ?? "",
    );

  }

}