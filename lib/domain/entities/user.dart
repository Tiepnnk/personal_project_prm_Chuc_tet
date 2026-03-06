class User {
  final int id;
  final String userName;
  final String? phone;
  final String? fullName;
  final String? avatar;

  const User({
    required this.id,
    required this.userName,
    this.phone,
    this.fullName,
    this.avatar,
  });

  User copyWith({
    int? id,
    String? userName,
    String? phone,
    String? fullName,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
    );
  }
}