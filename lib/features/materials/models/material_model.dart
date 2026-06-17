class MaterialModel {
  final String id;

  final String title;

  final String? description;

  final String subjectId;

  final String? topicId;

  final String fileUrl;

  final String fileName;

  final String fileType;

  final String uploadedBy;

  final DateTime? createdAt;

  const MaterialModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.uploadedBy,
    this.description,
    this.topicId,
    this.createdAt,
  });

  factory MaterialModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return MaterialModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description:
          map['description'] as String?,
      subjectId:
          map['subject_id'] as String,
      topicId:
          map['topic_id'] as String?,
      fileUrl:
          map['file_url'] as String,
      fileName:
          map['file_name'] as String,
      fileType:
          map['file_type'] as String,
      uploadedBy:
          map['uploaded_by'] as String,
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(
                  map['created_at'],
                )
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'topic_id': topicId,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'created_at':
          createdAt?.toIso8601String(),
    };
  }
}