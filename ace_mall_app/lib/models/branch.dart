class Branch {
  final String id;
  final String name;
  final String location;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'is_active': isActive,
    };
  }
}
