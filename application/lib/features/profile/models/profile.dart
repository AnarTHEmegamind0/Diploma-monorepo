class Profile {
  const Profile({
    required this.displayName,
    this.email,
    required this.phone,
    this.groupName,
    required this.roleLabel,
  });

  final String displayName;
  final String? email;
  final String phone;
  final String? groupName;
  final String roleLabel;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      displayName: json['name']?.toString() ?? json['auditor_name']?.toString() ?? 'Хэрэглэгч',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '',
      groupName: json['group_name']?.toString(),
      roleLabel: json['is_admin'] == true ? 'Админ' : 'Аудитор',
    );
  }
}
