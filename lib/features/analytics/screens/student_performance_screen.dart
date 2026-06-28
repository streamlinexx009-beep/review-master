import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentPerformanceScreen extends ConsumerStatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  ConsumerState<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends ConsumerState<StudentPerformanceScreen> {
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
          _PerformanceHeader(
            selectedSubjectName: selectedSubjectName,
            selectedStudentName: selectedStudentName,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 1120;

                final subjectsPanel = _SubjectsPanel(
                  selectedSubjectId: selectedSubjectId,
                  onSelect: (subject) {
                    setState(() {
                      selectedSubjectId = subject.id;
                      selectedSubjectName = subject.name;
                      selectedStudentId = null;
                      selectedStudentName = null;
                    });
                  },
                );

                final studentsPanel = _StudentsPanel(
                  subjectId: selectedSubjectId,
                  selectedStudentId: selectedStudentId,
                  onSelect: (student) {
                    setState(() {
                      selectedStudentId = student.id;
                      selectedStudentName = student.name;
                    });
                  },
                );

                final progressPanel = _StudentProgressPanel(
                  subjectId: selectedSubjectId,
                  subjectName: selectedSubjectName,
                  studentId: selectedStudentId,
                  studentName: selectedStudentName,
                );

                if (compact) {
                  return ListView(
                    children: [
                      SizedBox(height: 390, child: subjectsPanel),
                      const SizedBox(height: 16),
                      SizedBox(height: 390, child: studentsPanel),
                      const SizedBox(height: 16),
                      SizedBox(height: 560, child: progressPanel),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 310, child: subjectsPanel),
                    const SizedBox(width: 16),
                    SizedBox(width: 340, child: studentsPanel),
                    const SizedBox(width: 16),
                    Expanded(child: progressPanel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceHeader extends StatelessWidget {
  final String? selectedSubjectName;
  final String? selectedStudentName;

  const _PerformanceHeader({required this.selectedSubjectName, required this.selectedStudentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0F2FE)],
        ),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.insights_rounded, color: Color(0xFF4F46E5), size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Performance',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedStudentName == null
                      ? 'Choose a subject, then select an enrolled student to monitor progress.'
                      : 'Monitoring $selectedStudentName in ${selectedSubjectName ?? 'selected subject'}.',
                  style: const TextStyle(color: Color(0xFF475569), height: 1.4),
                ),
              ],
            ),
          ),
          if (selectedSubjectName != null)
            _StatusPill(icon: Icons.menu_book_rounded, label: selectedSubjectName!),
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
      title: '1. Subjects',
      subtitle: 'Pick the class you want to inspect.',
      child: FutureBuilder<List<_SubjectItem>>(
        future: _loadSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _InlineError(message: snapshot.error.toString());
          }

          final subjects = snapshot.data ?? [];
          if (subjects.isEmpty) {
            return const _EmptyHint(icon: Icons.menu_book_outlined, message: 'No subjects available yet.');
          }

          return ListView.separated(
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final selected = subject.id == selectedSubjectId;

              return _SelectableTile(
                selected: selected,
                icon: Icons.menu_book_rounded,
                title: subject.name,
                subtitle: subject.description ?? 'No section details',
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
      title: '2. Enrolled Students',
      subtitle: subjectId == null ? 'Select a subject first.' : 'Pick a student to monitor.',
      child: subjectId == null
          ? const _EmptyHint(icon: Icons.arrow_back_rounded, message: 'Choose a subject to load enrolled students.')
          : FutureBuilder<List<_StudentItem>>(
              future: _loadStudents(subjectId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _InlineError(message: snapshot.error.toString());
                }

                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const _EmptyHint(icon: Icons.person_off_outlined, message: 'No students enrolled in this subject yet.');
                }

                return ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final selected = student.id == selectedStudentId;

                    return _SelectableTile(
                      selected: selected,
                      icon: Icons.person_rounded,
                      title: student.name,
                      subtitle: student.email ?? 'No email available',
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
        title: '3. Progress Monitor',
        message: 'Select a subject first. The student list will appear in the middle panel.',
      );
    }

    if (studentId == null) {
      return const _EmptyProgressMessage(
        title: '3. Progress Monitor',
        message: 'Select an enrolled student to view exam attempts and performance summary.',
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
            return _InlineError(message: snapshot.error.toString());
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
                  final count = constraints.maxWidth < 720 ? 2 : 4;
                  return GridView.count(
                    crossAxisCount: count,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      _MiniStat(title: 'Attempts', value: '${data.attempts}', icon: Icons.assignment_outlined, color: const Color(0xFF0EA5E9)),
                      _MiniStat(title: 'Average', value: '${data.averageScore.toStringAsFixed(0)}%', icon: Icons.trending_up, color: const Color(0xFF8B5CF6)),
                      _MiniStat(title: 'Best', value: '${data.bestScore.toStringAsFixed(0)}%', icon: Icons.emoji_events_outlined, color: const Color(0xFFF97316)),
                      _MiniStat(title: 'Passed', value: '${data.passed}', icon: Icons.check_circle_outline, color: const Color(0xFF10B981)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Text('Exam Performance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                  _StatusPill(icon: Icons.close_rounded, label: '${data.failed} failed'),
                ],
              ),
              const SizedBox(height: 12),
              if (data.rows.isEmpty)
                const _EmptyHint(icon: Icons.fact_check_outlined, message: 'No exam attempts yet for this subject.')
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
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
                          DataCell(_ResultBadge(passed: row.passed)),
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
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? const Color(0xFF14B8A6) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected ? const Color(0xFFCCFBF1) : Colors.white,
              child: Icon(icon, color: selected ? const Color(0xFF0F766E) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFF0F766E)),
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
  final Color color;

  const _MiniStat({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF475569)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF475569))),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool passed;

  const _ResultBadge({required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        passed ? 'Passed' : 'Failed',
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyHint({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 28, child: Icon(icon)),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF991B1B))),
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
      subtitle: 'Follow the step-by-step panels from left to right.',
      child: _EmptyHint(icon: Icons.touch_app_rounded, message: message),
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
