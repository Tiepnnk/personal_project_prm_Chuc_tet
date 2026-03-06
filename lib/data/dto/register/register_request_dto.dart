class RegisterRequestDto {
  final String userName;
  final String password;
  final String? phone;
  final String? fullName;
  final String? avatar;

  const RegisterRequestDto({
    required this.userName,
    required this.password,
    this.phone,
    this.fullName,
    this.avatar,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
    'phone': phone,
    'fullName': fullName,
    'avatar': avatar,
  };
}
