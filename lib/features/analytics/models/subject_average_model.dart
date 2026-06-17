class SubjectAverageModel {

  final String subjectName;

  final double average;

  const SubjectAverageModel({
    required this.subjectName,
    required this.average,
  });

  factory SubjectAverageModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return SubjectAverageModel(
      subjectName:
          map['subject_name'],
      average:
          (map['average']
                  as num)
              .toDouble(),
    );
  }
}