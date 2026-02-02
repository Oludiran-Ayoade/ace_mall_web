class Department {
  final String id;
  final String name;
  final String? description;
  final bool isActive;

  Department({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}

class SubDepartment {
  final String id;
  final String departmentId;
  final String name;
  final String? description;
  final bool isActive;

  SubDepartment({
    required this.id,
    required this.departmentId,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory SubDepartment.fromJson(Map<String, dynamic> json) {
    return SubDepartment(
      id: json['id'],
      departmentId: json['department_id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department_id': departmentId,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}
