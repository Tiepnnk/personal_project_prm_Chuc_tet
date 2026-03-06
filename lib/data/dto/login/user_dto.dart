class UserDto {
  final int id;
  final String userName;
  final String? phone;
  final String? fullName;
  final String? avatar;

  const UserDto({
    required this.id,
    required this.userName,
    this.phone,
    this.fullName,
    this.avatar,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        userName: (json['userName'] ?? '').toString(),
        phone: json['phone']?.toString(),
        fullName: json['fullName']?.toString(),
        avatar: json['avatar']?.toString(),
    );
  }

  // Dùng cho SQL Lite
  factory UserDto.fromMap(Map<String,dynamic> map){
    return UserDto(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      userName: (map['user_name']?? map['username'] ?? map['userName'] ?? '').toString(),
      phone: map['phone']?.toString(),
      fullName: map['full_name']?.toString() ?? map['fullName']?.toString(),
      avatar: map['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'phone': phone,
    'fullName': fullName,
    'avatar': avatar,
  };
}