import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/ai_teacher_service.dart';

class AiTeacherToolsScreen extends StatefulWidget {
  final String subjectId;

  const AiTeacherToolsScreen({
    super.key,
    required this.subjectId,
  });

  @override
  State<AiTeacherToolsScreen> createState() => _AiTeacherToolsScreenState();
}

class _AiTeacherToolsScreenState extends State<AiTeacherToolsScreen> {
  final client = Supabase.instance.client;
  final topicController = TextEditingController();
  final countController = TextEditingController(text: '10');
  final essayQuestionController = TextEditingController();
  final essayAnswerController = TextEditingController();
  final rubricController = TextEditingController(text: 'Accuracy, completeness, clarity, examples');
  final resultDataController = TextEditingController();

  String action = 'generate_flashcards';
  String difficulty = 'medium';
  bool loading = false;
  bool saving = false;
  Map<String, dynamic>? aiResponse;
  String? error;

  @override
  void dispose() {
    topicController.dispose();
    countController.dispose();
    essayQuestionController.dispose();
    essayAnswerController.dispose();
    rubricController.dispose();
    resultDataController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadSubject() async {
    final data = await client
        .from('subjects')
        .select('id, name, description')
        .eq('id', widget.subjectId)
        .single();
    return Map<String, dynamic>.from(data);
  }

  Future<void> _runAi(Map<String, dynamic> subject) async {
    setState(() {
      loading = true;
      error = null;
      aiResponse = null;
    });

    try {
      Map<String, dynamic>? resultData;
      if (resultDataController.text.trim().isNotEmpty) {
        resultData = jsonDecode(resultDataController.text.trim()) as Map<String, dynamic>;
      }

      final service = AiTeacherService(client);
      final response = await service.run(
        action: action,
        payload: {
          'subjectId': widget.subjectId,
          'subject': subject['name'],
          'topic': topicController.text.trim().isEmpty ? 'General topic' : topicController.text.trim(),
          'difficulty': difficulty,
          'count': int.tryParse(countController.text.trim()) ?? 10,
          'question': essayQuestionController.text.trim(),
          'answer': essayAnswerController.text.trim(),
          'rubric': rubricController.text.trim(),
          'maxScore': 10,
          'resultData': resultData ?? {},
        },
      );

      setState(() => aiResponse = response['result'] as Map<String, dynamic>?);
    } catch (e) {
      setState(() => error = e.toString());
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> _saveGenerated(Map<String, dynamic> subject) async {
    if (aiResponse == null) return;

    setState(() => saving = true);

    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (action == 'generate_flashcards') {
        final flashcards = (aiResponse!['flashcards'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((item) => {
                  'subject_id': widget.subjectId,
                  'front_text': (item['front'] ?? '').toString(),
                  'back_text': (item['back'] ?? '').toString(),
                  'created_by': user.id,
                })
            .where((item) => item['front_text'].toString().trim().isNotEmpty && item['back_text'].toString().trim().isNotEmpty)
            .toList();

        if (flashcards.isEmpty) throw Exception('No valid flashcards to save.');
        await client.from('flashcards').insert(flashcards);
      }

      if (action == 'generate_exam') {
        final title = (aiResponse!['title'] ?? '${subject['name']} AI Exam').toString();
        final description = (aiResponse!['description'] ?? 'AI-generated exam').toString();
        final passingScore = int.tryParse((aiResponse!['passing_score'] ?? 75).toString()) ?? 75;
        final timeLimit = int.tryParse((aiResponse!['time_limit'] ?? 30).toString()) ?? 30;

        final exam = await client
            .from('exams')
            .insert({
              'title': title,
              'description': description,
              'subject_id': widget.subjectId,
              'passing_score': passingScore,
              'time_limit': timeLimit,
              'created_by': user.id,
            })
            .select('id')
            .single();

        final examId = exam['id'] as String;
        final questions = (aiResponse!['questions'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((item) {
              final choices = (item['choices'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
              while (choices.length < 4) {
                choices.add('Option ${choices.length + 1}');
              }
              return {
                'exam_id': examId,
                'question_text': (item['question'] ?? '').toString(),
                'option_a': choices[0],
                'option_b': choices[1],
                'option_c': choices[2],
                'option_d': choices[3],
                'correct_answer': (item['answer'] ?? choices[0]).toString(),
              };
            })
            .where((item) => item['question_text'].toString().trim().isNotEmpty)
            .toList();

        if (questions.isNotEmpty) {
          await client.from('exam_questions').insert(questions);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action == 'generate_flashcards' ? 'AI flashcards saved.' : 'AI exam saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadSubject(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final subject = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(subjectName: subject['name'].toString()),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 1050;
                  final form = _FormPanel(
                    action: action,
                    difficulty: difficulty,
                    topicController: topicController,
                    countController: countController,
                    essayQuestionController: essayQuestionController,
                    essayAnswerController: essayAnswerController,
                    rubricController: rubricController,
                    resultDataController: resultDataController,
                    onActionChanged: (value) => setState(() {
                      action = value;
                      aiResponse = null;
                      error = null;
                    }),
                    onDifficultyChanged: (value) => setState(() => difficulty = value),
                    onRun: loading ? null : () => _runAi(subject),
                    loading: loading,
                  );
                  final preview = _PreviewPanel(
                    action: action,
                    response: aiResponse,
                    error: error,
                    saving: saving,
                    onSave: (action == 'generate_flashcards' || action == 'generate_exam') && aiResponse != null
                        ? () => _saveGenerated(subject)
                        : null,
                  );

                  if (narrow) {
                    return Column(
                      children: [
                        form,
                        const SizedBox(height: 16),
                        preview,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 430, child: form),
                      const SizedBox(width: 16),
                      Expanded(child: preview),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  final String subjectName;

  const _Hero({required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [Color(0xFFF0FDFA), Color(0xFFE0F2FE)]),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.auto_awesome_rounded)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Teacher Tools', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Generate flashcards, create exams, analyze results, and check essays for $subjectName.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  final String action;
  final String difficulty;
  final TextEditingController topicController;
  final TextEditingController countController;
  final TextEditingController essayQuestionController;
  final TextEditingController essayAnswerController;
  final TextEditingController rubricController;
  final TextEditingController resultDataController;
  final ValueChanged<String> onActionChanged;
  final ValueChanged<String> onDifficultyChanged;
  final VoidCallback? onRun;
  final bool loading;

  const _FormPanel({
    required this.action,
    required this.difficulty,
    required this.topicController,
    required this.countController,
    required this.essayQuestionController,
    required this.essayAnswerController,
    required this.rubricController,
    required this.resultDataController,
    required this.onActionChanged,
    required this.onDifficultyChanged,
    required this.onRun,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What do you want AI to do?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: action,
            decoration: const InputDecoration(labelText: 'AI action', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'generate_flashcards', child: Text('Generate random flashcards')),
              DropdownMenuItem(value: 'generate_exam', child: Text('Generate exam')),
              DropdownMenuItem(value: 'analyze_results', child: Text('Analyze result data')),
              DropdownMenuItem(value: 'check_essay', child: Text('Check essay / assignment')),
            ],
            onChanged: (value) {
              if (value != null) onActionChanged(value);
            },
          ),
          const SizedBox(height: 12),
          if (action == 'generate_flashcards' || action == 'generate_exam') ...[
            TextField(controller: topicController, decoration: const InputDecoration(labelText: 'Topic', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'hard', child: Text('Hard')),
                    ],
                    onChanged: (value) {
                      if (value != null) onDifficultyChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Count', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
          if (action == 'analyze_results')
            TextField(
              controller: resultDataController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Result data JSON',
                hintText: '{"average":72,"common_mistakes":["..."]}',
                border: OutlineInputBorder(),
              ),
            ),
          if (action == 'check_essay') ...[
            TextField(controller: essayQuestionController, maxLines: 2, decoration: const InputDecoration(labelText: 'Question / instruction', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: essayAnswerController, maxLines: 6, decoration: const InputDecoration(labelText: 'Student answer', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: rubricController, maxLines: 3, decoration: const InputDecoration(labelText: 'Rubric', border: OutlineInputBorder())),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRun,
              icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome_rounded),
              label: Text(loading ? 'Generating...' : 'Generate with AI'),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Teacher must review AI output before saving or approving scores.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final String action;
  final Map<String, dynamic>? response;
  final String? error;
  final VoidCallback? onSave;
  final bool saving;

  const _PreviewPanel({
    required this.action,
    required this.response,
    required this.error,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('AI Preview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              if (onSave != null)
                FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded),
                  label: Text(action == 'generate_flashcards' ? 'Save Flashcards' : 'Save Exam'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (error != null)
            _ErrorBox(message: error!)
          else if (response == null)
            const _EmptyPreview()
          else
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(response),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
        ],
      ),
    );
  }
}

class _ModernCard extends StatelessWidget {
  final Widget child;

  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text('Generated AI output will appear here for teacher review.'),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF991B1B))),
    );
  }
}
