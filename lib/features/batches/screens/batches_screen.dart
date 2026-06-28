import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/batch_providers.dart';
import 'create_batch_screen.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          child: batchesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _ErrorState(message: error.toString()),
            data: (batches) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BatchesHeader(
                    count: batches.length,
                    onCreate: () => _showCreateBatchDialog(context),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: batches.isEmpty
                        ? _EmptyBatches(onCreate: () => _showCreateBatchDialog(context))
                        : ListView.separated(
                            itemCount: batches.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final batch = batches[index];
                              return _BatchRowCard(
                                title: batch.name,
                                description: batch.description ?? 'No description added yet',
                                onOpen: () => context.go('/batches/${batch.id}'),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCreateBatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CreateBatchScreen(),
    );
  }
}

class _BatchesHeader extends StatelessWidget {
  final int count;
  final VoidCallback onCreate;

  const _BatchesHeader({required this.count, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)]),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.groups_rounded, color: Color(0xFF0284C7), size: 34),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Batches', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                const Text('Organize students into class groups, then assign subjects to the group.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
                const SizedBox(height: 12),
                _CountPill(count: count),
              ],
            ),
          ),
          const SizedBox(width: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Batch'),
          ),
        ],
      ),
    );
  }
}

class _BatchRowCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onOpen;

  const _BatchRowCard({required this.title, required this.description, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.groups_rounded, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              FilledButton.tonalIcon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(99)),
      child: Text('$count batch${count == 1 ? '' : 'es'}', style: const TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _EmptyBatches extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyBatches({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: Padding(
            padding: const EdgeInsets.all(34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 34, child: Icon(Icons.groups_rounded)),
                const SizedBox(height: 18),
                Text('No batches yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Create a batch to group students and assign subjects more easily.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
                const SizedBox(height: 18),
                FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add_rounded), label: const Text('Create Batch')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message, textAlign: TextAlign.center));
  }
}
