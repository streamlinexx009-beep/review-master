class SubjectModel {
  final String id;

  final String name;

  final String? description;

  final String createdBy;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.createdBy,
    this.description,
  });

  factory SubjectModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return SubjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description:
          map['description'] as String?,
      createdBy:
          map['created_by'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description ?? this.description,
      createdBy:
          createdBy ?? this.createdBy,
    );
  }
}