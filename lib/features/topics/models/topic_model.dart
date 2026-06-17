class TopicModel {
  final String id;
  final String subjectId;
  final String name;
  final String? description;

  /// Controls the order topics appear in a subject
  final int displayOrder;

  /// Allows topics to be archived or hidden
  final bool isActive;

  const TopicModel({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory TopicModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return TopicModel(
      id: map['id']?.toString() ?? '',
      subjectId: map['subject_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      displayOrder: map['display_order'] ?? 0,
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }

  TopicModel copyWith({
    String? id,
    String? subjectId,
    String? name,
    String? description,
    int? displayOrder,
    bool? isActive,
  }) {
    return TopicModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'TopicModel('
        'id: $id, '
        'subjectId: $subjectId, '
        'name: $name, '
        'description: $description, '
        'displayOrder: $displayOrder, '
        'isActive: $isActive'
        ')';
  }
}