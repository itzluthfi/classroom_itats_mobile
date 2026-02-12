class SubjectMember {
  String userId;
  String name;
  String phoneNumber;
  int presence;

  SubjectMember({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.presence,
  });

  factory SubjectMember.fromJson(Map<String, dynamic> json) => SubjectMember(
        userId: json["user_id"],
        name: json["name"],
        phoneNumber: json["phone_number"],
        presence: json["presence"],
      );
}
