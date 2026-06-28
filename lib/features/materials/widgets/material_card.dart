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
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => _openPdf(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 30),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      material.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 10),
                    const Wrap(
                      spacing: 8,
                      children: [
                        _MaterialChip(icon: Icons.description_outlined, label: 'PDF'),
                        _MaterialChip(icon: Icons.visibility_outlined, label: 'Ready to view'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () => _openPdf(context),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPdf(BuildContext context) {
    context.go(
      '/pdf-viewer',
      extra: {
        'title': material.title,
        'pdfUrl': material.fileUrl,
      },
    );
  }
}

class _MaterialChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MaterialChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
