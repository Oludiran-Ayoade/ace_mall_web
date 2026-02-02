class Role {
  final String id;
  final String name;
  final String category; // senior_admin, admin, general
  final String? departmentId;
  final String? departmentName;
  final String? subDepartmentId;
  final String? subDepartmentName;
  final String? description;
  final bool isActive;

  Role({
    required this.id,
    required this.name,
    required this.category,
    this.departmentId,
    this.departmentName,
    this.subDepartmentId,
    this.subDepartmentName,
    this.description,
    required this.isActive,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      subDepartmentId: json['sub_department_id'],
      subDepartmentName: json['sub_department_name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'department_id': departmentId,
      'department_name': departmentName,
      'sub_department_id': subDepartmentId,
      'sub_department_name': subDepartmentName,
      'description': description,
      'is_active': isActive,
    };
  }

  // Helper method to get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'senior_admin':
        return 'Senior Admin';
      case 'admin':
        return 'Admin';
      case 'general':
        return 'General Staff';
      default:
        return category;
    }
  }
}
