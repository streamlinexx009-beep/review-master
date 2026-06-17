import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/material_model.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;

  const MaterialCard({
    super.key,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Theme.of(context).colorScheme.error,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    material.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              tooltip: 'View PDF',
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () {
                debugPrint(
                  'PDF URL: ${material.fileUrl}',
                );

                context.go(
                  '/pdf-viewer',
                  extra: {
                    'title': material.title,
                    'pdfUrl': material.fileUrl,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}