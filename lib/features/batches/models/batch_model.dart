class BatchModel {
  final String id;
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const BatchModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory BatchModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return BatchModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      startDate: map['start_date'] != null
          ? DateTime.parse(
              map['start_date'],
            )
          : null,
      endDate: map['end_date'] != null
          ? DateTime.parse(
              map['end_date'],
            )
          : null,
      isActive:
          map['is_active'] ?? true,
    );
  }
}