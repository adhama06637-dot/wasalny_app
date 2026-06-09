class User {
  String id;
  String name;
  String email;
  String? phone;
  String? photo_url;
  String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo_url,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photo_url: json['photo_url'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (photo_url != null) 'photo_url': photo_url,
      if (token != null) 'token': token,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photo_url,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo_url: photo_url ?? this.photo_url,
      token: token ?? this.token,
    );
  }
}