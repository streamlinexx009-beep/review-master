import 'dart:typed_data';
import 'package:go_router/go_router.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/material_provider.dart';
import '../../../core/services/material_storage_service.dart';

class UploadMaterialScreen
    extends ConsumerStatefulWidget {
  final String subjectId;

  const UploadMaterialScreen({
    super.key,
    required this.subjectId,
  });

  @override
  ConsumerState<UploadMaterialScreen>
      createState() =>
          _UploadMaterialScreenState();
}

class _UploadMaterialScreenState
    extends ConsumerState<
        UploadMaterialScreen> {
  final titleController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  Uint8List? selectedFileBytes;

  String? selectedFileName;

  bool uploading = false;

  Future<void> pickPdf() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedFileBytes =
          result.files.first.bytes;

      selectedFileName =
          result.files.first.name;
    });
  }

  Future<void> uploadMaterial() async {
    if (selectedFileBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a PDF file',
          ),
        ),
      );
      return;
    }

    if (titleController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a title',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        uploading = true;
      });

      final fileUrl =
          await MaterialStorageService
              .uploadPdf(
        bytes: selectedFileBytes!,
        fileName: selectedFileName!,
      );

      await ref
          .read(
            materialRepositoryProvider,
          )
          .uploadMaterial(
            title:
                titleController.text.trim(),
            description:
                descriptionController.text
                        .trim()
                        .isEmpty
                    ? null
                    : descriptionController
                        .text
                        .trim(),
            fileName:
                selectedFileName!,
            fileUrl: fileUrl,
            subjectId:
                widget.subjectId,
          );

      ref.invalidate(
        materialsProvider,
      );

      if (mounted) {
  ref.invalidate(materialsProvider);

  context.go(
    '/subjects/${widget.subjectId}/materials',
  );
}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          uploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Material',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints:
                const BoxConstraints(
              maxWidth: 700,
            ),
            padding:
                const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Review Material',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Text(
                        'Subject ID: ${widget.subjectId}',
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    TextField(
                      controller:
                          titleController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Material Title',
                        prefixIcon: Icon(
                          Icons.title,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          descriptionController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Description',
                        alignLabelWithHint:
                            true,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    if (selectedFileName !=
                        null)
                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(
                          16,
                        ),
                        margin:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .outline,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                selectedFileName!,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            pickPdf,
                        icon: const Icon(
                          Icons.upload_file,
                        ),
                        label: Text(
                          selectedFileName ==
                                  null
                              ? 'Select PDF File'
                              : 'Change PDF File',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed:
                            uploading
                                ? null
                                : uploadMaterial,
                        icon: const Icon(
                          Icons.cloud_upload,
                        ),
                        label: Text(
                          uploading
                              ? 'Uploading...'
                              : 'Upload Material',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}