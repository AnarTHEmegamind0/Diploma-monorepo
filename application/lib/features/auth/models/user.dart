class User {
  const User({
    required this.id,
    required this.phone,
    this.email,
    this.name,
    this.token,
    this.groupId,
    this.groupName,
    this.isAdmin = false,
    this.isActive = true,
  });

  final String id;
  final String phone;
  final String? email;
  final String? name;
  final String? token;
  final String? groupId;
  final String? groupName;
  final bool isAdmin;
  final bool isActive;

  String get roleLabel => isAdmin ? 'Админ' : 'Аудитор';

  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? token,
    String? groupId,
    String? groupName,
    bool? isAdmin,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:
          json['auditor_id']?.toString() ??
          json['id']?.toString() ??
          json['_id']?.toString() ??
          '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      name:
          json['auditor_name']?.toString() ??
          json['name']?.toString(),
      token: json['access_token']?.toString() ?? json['token']?.toString(),
      groupId: json['group_id']?.toString(),
      groupName: json['group_name']?.toString(),
      isAdmin: json['is_admin'] == true,
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'token': token,
      'group_id': groupId,
      'group_name': groupName,
      'is_admin': isAdmin,
      'is_active': isActive,
    };
  }
}
