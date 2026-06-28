import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentPerformanceScreen extends ConsumerStatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  ConsumerState<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends ConsumerState<StudentPerformanceScreen> {
  final supabase = Supabase.instance.client;

  String? selectedSubjectId;
  String? selectedSubjectName;
  String? selectedStudentId;
  String? selectedStudentName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Performance', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Choose a subject, select an enrolled student, then monitor the student performance and progress.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 320,
                  child: _SubjectsPanel(
                    selectedSubjectId: selectedSubjectId,
                    onSelect: (subject) {
                      setState(() {
                        selectedSubjectId = subject.id;
                        selectedSubjectName = subject.name;
                        selectedStudentId = null;
                        selectedStudentName = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 360,
                  child: _StudentsPanel(
                    subjectId: selectedSubjectId,
                    selectedStudentId: selectedStudentId,
                    onSelect: (student) {
                      setState(() {
                        selectedStudentId = student.id;
                        selectedStudentName = student.name;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _StudentProgressPanel(
                    subjectId: selectedSubjectId,
                    subjectName: selectedSubjectName,
                    studentId: selectedStudentId,
                    studentName: selectedStudentName,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectItem {
  final String id;
  final String name;
  final String? description;

  const _SubjectItem({required this.id, required this.name, this.description});
}

class _StudentItem {
  final String id;
  final String name;
  final String? email;

  const _StudentItem({required this.id, required this.name, this.email});
}

class _SubjectsPanel extends StatelessWidget {
  final String? selectedSubjectId;
  final ValueChanged<_SubjectItem> onSelect;

  const _SubjectsPanel({required this.selectedSubjectId, required this.onSelect});

  Future<List<_SubjectItem>> _loadSubjects() async {
    final data = await Supabase.instance.client
        .from('subjects')
        .select('id, name, description')
        .order('name');

    return data.map<_SubjectItem>((row) {
      return _SubjectItem(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String?,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Subjects',
      subtitle: 'Select a subject',
      child: FutureBuilder<List<_SubjectItem>>(
        future: _loadSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final subjects = snapshot.data ?? [];
          if (subjects.isEmpty) {
            return const Text('No subjects available.');
          }

          return ListView.separated(
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final selected = subject.id == selectedSubjectId;

              return ListTile(
                selected: selected,
                selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(subject.name),
                subtitle: Text(subject.description ?? 'No description'),
                onTap: () => onSelect(subject),
              );
            },
          );
        },
      ),
    );
  }
}

class _StudentsPanel extends StatelessWidget {
  final String? subjectId;
  final String? selectedStudentId;
  final ValueChanged<_StudentItem> onSelect;

  const _StudentsPanel({
    required this.subjectId,
    required this.selectedStudentId,
    required this.onSelect,
  });

  Future<List<_StudentItem>> _loadStudents(String subjectId) async {
    final data = await Supabase.instance.client
        .from('subject_students')
        .select('student_id, profiles!subject_students_student_id_fkey(id, full_name, email)')
        .eq('subject_id', subjectId)
        .order('created_at');

    return data.map<_StudentItem>((row) {
      final profile = row['profiles'] as Map<String, dynamic>?;
      final id = (profile?['id'] ?? row['student_id']) as String;
      final name = (profile?['full_name'] as String?)?.trim();
      final email = profile?['email'] as String?;

      return _StudentItem(
        id: id,
        name: name == null || name.isEmpty ? email ?? 'Unnamed student' : name,
        email: email,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Enrolled Students',
      subtitle: subjectId == null ? 'Select a subject first' : 'Select a student',
      child: subjectId == null
          ? const Center(child: Text('Choose a subject to see enrolled students.'))
          : FutureBuilder<List<_StudentItem>>(
              future: _loadStudents(subjectId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const Text('No students enrolled in this subject yet.');
                }

                return ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final selected = student.id == selectedStudentId;

                    return ListTile(
                      selected: selected,
                      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text(student.name),
                      subtitle: Text(student.email ?? 'No email'),
                      onTap: () => onSelect(student),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StudentProgressPanel extends StatelessWidget {
  final String? subjectId;
  final String? subjectName;
  final String? studentId;
  final String? studentName;

  const _StudentProgressPanel({
    required this.subjectId,
    required this.subjectName,
    required this.studentId,
    required this.studentName,
  });

  Future<_StudentProgressData> _loadProgress({
    required String subjectId,
    required String studentId,
  }) async {
    final attempts = await Supabase.instance.client
        .from('exam_attempts')
        .select('score, passed, exams!inner(id, title, subject_id)')
        .eq('student_id', studentId)
        .eq('exams.subject_id', subjectId);

    if (attempts.isEmpty) {
      return const _StudentProgressData(
        attempts: 0,
        averageScore: 0,
        bestScore: 0,
        passed: 0,
        failed: 0,
        rows: [],
      );
    }

    final rows = attempts.map<_AttemptRow>((row) {
      final exam = row['exams'] as Map<String, dynamic>?;
      return _AttemptRow(
        title: (exam?['title'] as String?) ?? 'Untitled exam',
        score: (row['score'] as num?)?.toDouble() ?? 0,
        passed: (row['passed'] as bool?) ?? false,
      );
    }).toList();

    final total = rows.length;
    final average = rows.fold<double>(0, (sum, row) => sum + row.score) / total;
    final best = rows.fold<double>(0, (best, row) => row.score > best ? row.score : best);
    final passed = rows.where((row) => row.passed).length;

    return _StudentProgressData(
      attempts: total,
      averageScore: average,
      bestScore: best,
      passed: passed,
      failed: total - passed,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (subjectId == null) {
      return const _EmptyProgressMessage(
        title: 'Select a subject',
        message: 'Choose a subject from the left panel to view enrolled students.',
      );
    }

    if (studentId == null) {
      return const _EmptyProgressMessage(
        title: 'Select a student',
        message: 'Choose a student to monitor his/her performance.',
      );
    }

    return _PanelCard(
      title: studentName ?? 'Student Progress',
      subtitle: subjectName ?? 'Subject performance',
      child: FutureBuilder<_StudentProgressData>(
        future: _loadProgress(subjectId: subjectId!, studentId: studentId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data ?? const _StudentProgressData(
            attempts: 0,
            averageScore: 0,
            bestScore: 0,
            passed: 0,
            failed: 0,
            rows: [],
          );

          return ListView(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 720;
                  final cards = [
                    _MiniStat(title: 'Attempts', value: '${data.attempts}', icon: Icons.assignment_outlined),
                    _MiniStat(title: 'Average', value: '${data.averageScore.toStringAsFixed(0)}%', icon: Icons.trending_up),
                    _MiniStat(title: 'Best', value: '${data.bestScore.toStringAsFixed(0)}%', icon: Icons.emoji_events_outlined),
                    _MiniStat(title: 'Passed', value: '${data.passed}', icon: Icons.check_circle_outline),
                  ];

                  if (narrow) {
                    return Column(children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 12), child: card)).toList());
                  }

                  return Row(children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: card))).toList());
                },
              ),
              const SizedBox(height: 20),
              Text('Exam Performance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (data.rows.isEmpty)
                const Text('No exam attempts yet for this subject.')
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Exam')),
                      DataColumn(label: Text('Score')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: data.rows.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(Text(row.title)),
                          DataCell(Text('${row.score.toStringAsFixed(0)}%')),
                          DataCell(Text(row.passed ? 'Passed' : 'Failed')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _PanelCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniStat({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 14),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _EmptyProgressMessage extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyProgressMessage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: title,
      subtitle: 'Student monitoring',
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

class _StudentProgressData {
  final int attempts;
  final double averageScore;
  final double bestScore;
  final int passed;
  final int failed;
  final List<_AttemptRow> rows;

  const _StudentProgressData({
    required this.attempts,
    required this.averageScore,
    required this.bestScore,
    required this.passed,
    required this.failed,
    required this.rows,
  });
}

class _AttemptRow {
  final String title;
  final double score;
  final bool passed;

  const _AttemptRow({required this.title, required this.score, required this.passed});
}
