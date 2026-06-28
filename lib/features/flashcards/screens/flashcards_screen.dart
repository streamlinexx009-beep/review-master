import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/flashcard_provider.dart';
import 'study_flashcards_screen.dart';

class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(flashcardsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ModuleHeader(
            title: 'Flashcards',
            subtitle: 'Review important terms and concepts using quick study cards.',
            icon: Icons.style_rounded,
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: flashcards.when(
              data: (items) {
                if (items.isEmpty) {
                  return const _EmptyState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Available Cards', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(99)),
                          child: Text('${items.length} card${items.length == 1 ? '' : 's'}', style: const TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => StudyFlashcardsScreen(flashcards: items)));
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Study All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 4;
                          if (constraints.maxWidth < 1300) crossAxisCount = 3;
                          if (constraints.maxWidth < 940) crossAxisCount = 2;
                          if (constraints.maxWidth < 650) crossAxisCount = 1;

                          return GridView.builder(
                            itemCount: items.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.12,
                            ),
                            itemBuilder: (_, index) {
                              final flashcard = items[index];
                              return _FlashcardTile(
                                frontText: flashcard.frontText,
                                backText: flashcard.backText,
                                onStudy: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudyFlashcardsScreen(flashcards: items)));
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString(), textAlign: TextAlign.center)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashcardTile extends StatelessWidget {
  final String frontText;
  final String backText;
  final VoidCallback onStudy;

  const _FlashcardTile({required this.frontText, required this.backText, required this.onStudy});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onStudy,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.style_rounded, color: Color(0xFF7C3AED)),
                  ),
                  const Spacer(),
                  const _CardBadge(label: 'Review'),
                ],
              ),
              const SizedBox(height: 18),
              Text(frontText, maxLines: 3, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              const SizedBox(height: 10),
              Text(backText, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
              const Spacer(),
              SizedBox(width: double.infinity, child: FilledButton.tonalIcon(onPressed: onStudy, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Study'))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ModuleHeader({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(colors: [color.withOpacity(0.14), Colors.white]), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(22)), child: Icon(icon, color: color, size: 34)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  final String label;
  const _CardBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: Padding(
            padding: const EdgeInsets.all(34),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircleAvatar(radius: 34, child: Icon(Icons.style_outlined)),
              const SizedBox(height: 18),
              Text('No flashcards yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Flashcards created by teachers will appear here for quick review.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
            ]),
          ),
        ),
      ),
    );
  }
}
