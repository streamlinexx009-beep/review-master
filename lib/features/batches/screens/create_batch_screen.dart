import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/batch_providers.dart';

class CreateBatchScreen
    extends ConsumerStatefulWidget {
  const CreateBatchScreen({
    super.key,
  });

  @override
  ConsumerState<CreateBatchScreen>
      createState() =>
          _CreateBatchScreenState();
}

class _CreateBatchScreenState
    extends ConsumerState<
        CreateBatchScreen> {
  final _nameController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBatch() async {
    if (_nameController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Batch name is required.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(
            batchRepositoryProvider,
          )
          .createBatch(
            name:
                _nameController.text
                    .trim(),
            description:
                _descriptionController
                    .text
                    .trim(),
          );

      ref.invalidate(
        batchesProvider,
      );

      if (mounted) {
        Navigator.pop(
          context,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Create Batch',
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
            ),
            onPressed:
                _isSaving
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                        );
                      },
          ),
        ],
      ),

      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  _nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Batch Name',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _descriptionController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Description',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),

      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isSaving
                    ? null
                    : _saveBatch,
            child:
                _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                        ),
                      )
                    : const Text(
                        'Save',
                      ),
          ),
        ),
      ],
    );
  }
}

