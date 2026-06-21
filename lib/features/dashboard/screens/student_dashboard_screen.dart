import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Review Master! 👋',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your average activity this week is 75%, it is very good enough.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  '01 Aug 2026',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 1200
                  ? 4
                  : constraints.maxWidth > 760
                      ? 2
                      : 1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: count,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: count == 1 ? 2.25 : 1.75,
                children: const [
                  _MetricCard(
                    title: 'Total class',
                    value: '100',
                    trend: '15%',
                    positive: true,
                    variant: _MetricVariant.bars,
                  ),
                  _MetricCard(
                    title: 'Total students',
                    value: '124',
                    trend: '10%',
                    positive: true,
                    variant: _MetricVariant.line,
                  ),
                  _MetricCard(
                    title: 'Gross score',
                    value: '91%',
                    trend: '10%',
                    positive: false,
                    variant: _MetricVariant.profit,
                  ),
                  _MetricCard(
                    title: 'Total visits',
                    value: '248k',
                    trend: '25%',
                    positive: true,
                    variant: _MetricVariant.bars,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 36),
          _SectionHeader(
            title: 'Upcoming class',
            subtitle: 'Today, you have 3 upcoming class',
            action: 'More',
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 194,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _ClassCard(
                  highlighted: true,
                  title: 'Contextual understanding and design process flow',
                  label: 'UI/UX FUNDAMENTAL',
                  time: '14 Hours',
                  buttonText: 'START THE CLASS',
                ),
                _ClassCard(
                  title: 'Introduction to foundation of desk research and how to present',
                  label: 'UI/UX FUNDAMENTAL',
                  time: '20 Hours',
                  buttonText: 'UPCOMING CLASS',
                ),
                _ClassCard(
                  title: 'Basic illustration and adobe illustrator',
                  label: 'UI/UX FUNDAMENTAL',
                  time: '18 Hours',
                  buttonText: 'UPCOMING CLASS',
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Classroom',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const _FilterButton(label: 'All category'),
              const SizedBox(width: 14),
              const _FilterButton(label: 'All status'),
              const Spacer(),
              SizedBox(
                width: 260,
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search class',
                    prefixIcon: const Icon(Icons.search_rounded),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _ClassroomTable(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}

enum _MetricVariant { bars, line, profit }

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool positive;
  final _MetricVariant variant;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.positive,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  variant == _MetricVariant.profit ? 'Export' : 'View details',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _TrendPill(trend: trend, positive: positive),
                    ],
                  ),
                ),
                SizedBox(
                  width: 116,
                  height: 86,
                  child: _MiniChart(variant: variant, positive: positive),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final String trend;
  final bool positive;

  const _TrendPill({required this.trend, required this.positive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: positive ? AppColors.primarySoft : AppColors.errorSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 15,
            color: positive ? AppColors.primary : AppColors.error,
          ),
          Text(
            trend,
            style: TextStyle(
              color: positive ? AppColors.primary : AppColors.error,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final _MetricVariant variant;
  final bool positive;

  const _MiniChart({required this.variant, required this.positive});

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case _MetricVariant.line:
        return CustomPaint(painter: _LineChartPainter());
      case _MetricVariant.profit:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            _ChartBar(height: 36, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 28, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 50, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 38, color: AppColors.error),
          ],
        );
      case _MetricVariant.bars:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const _ChartBar(height: 56, color: Color(0xFFF0F2F5)),
            const _ChartBar(height: 42, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 78, color: positive ? AppColors.primary : AppColors.error),
            const _ChartBar(height: 60, color: Color(0xFFF0F2F5)),
          ],
        );
    }
  }
}

class _ChartBar extends StatelessWidget {
  final double height;
  final Color color;

  const _ChartBar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: height,
      margin: const EdgeInsets.only(left: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * .82)
      ..cubicTo(size.width * .18, size.height * .12, size.width * .28, size.height * .88, size.width * .42, size.height * .33)
      ..cubicTo(size.width * .58, -6, size.width * .73, size.height * .95, size.width, size.height * .05);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClassCard extends StatelessWidget {
  final bool highlighted;
  final String title;
  final String label;
  final String time;
  final String buttonText;

  const _ClassCard({
    this.highlighted = false,
    required this.title,
    required this.label,
    required this.time,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final background = highlighted ? AppColors.primary : AppColors.surface;
    final foreground = highlighted ? Colors.white : AppColors.text;

    return Container(
      width: highlighted ? 390 : 390,
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: highlighted ? Colors.transparent : AppColors.border),
        boxShadow: highlighted
            ? const [
                BoxShadow(
                  color: Color(0x330F9F9A),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: highlighted ? Colors.white : AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: highlighted ? Colors.white.withOpacity(.16) : AppColors.mutedSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
          ),
          const Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: highlighted ? AppColors.secondary : Colors.transparent,
                  foregroundColor: highlighted ? Colors.white : AppColors.secondary,
                  side: BorderSide(color: highlighted ? AppColors.secondary : AppColors.secondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(buttonText),
              ),
              const Spacer(),
              const _AvatarStack(),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      height: 34,
      child: Stack(
        children: const [
          _SmallAvatar(left: 0, color: Color(0xFFFFD4BA)),
          _SmallAvatar(left: 22, color: Color(0xFFECC7B8)),
          _SmallAvatar(left: 44, color: Color(0xFFBFE3DD)),
          Positioned(
            left: 66,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryDark,
              child: Text('+22', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  final double left;
  final Color color;

  const _SmallAvatar({required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        child: CircleAvatar(radius: 14, backgroundColor: color, child: const Icon(Icons.person, size: 15, color: AppColors.text)),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;

  const _FilterButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 34),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }
}

class _ClassroomTable extends StatelessWidget {
  const _ClassroomTable();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: const [
            _TableRowItem(header: true),
            Divider(height: 1, color: AppColors.border),
            _TableRowItem(
              title: 'UI/UX fundamental',
              category: 'UI/UX',
              duration: '14 Hours',
              status: 'In progress',
              completed: '9/16 Completed',
              progress: .72,
            ),
            Divider(height: 1, color: AppColors.border),
            _TableRowItem(
              title: 'Anatomy mastery review',
              category: 'Science',
              duration: '10 Hours',
              status: 'Upcoming',
              completed: '4/12 Completed',
              progress: .34,
            ),
            Divider(height: 1, color: AppColors.border),
            _TableRowItem(
              title: 'Pharmacology drills',
              category: 'Health',
              duration: '18 Hours',
              status: 'Completed',
              completed: '20/20 Completed',
              progress: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  final bool header;
  final String title;
  final String category;
  final String duration;
  final String status;
  final String completed;
  final double progress;

  const _TableRowItem({
    this.header = false,
    this.title = 'Class title',
    this.category = 'Category',
    this.duration = 'Duration',
    this.status = 'Status',
    this.completed = 'Completion rate',
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: header ? FontWeight.w800 : FontWeight.w600,
      color: header ? AppColors.text : AppColors.textMuted,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      color: header ? AppColors.surface : Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Checkbox(value: false, onChanged: header ? (_) {} : (_) {}),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(title, style: style)),
          Expanded(flex: 2, child: header ? Text('Student', style: style) : const _AvatarStack()),
          Expanded(flex: 2, child: Text(category, style: style)),
          Expanded(flex: 2, child: Text(duration, style: style)),
          Expanded(
            flex: 2,
            child: header
                ? Text(status, style: style)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: status == 'In progress' ? AppColors.secondarySoft : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
          ),
          Expanded(
            flex: 2,
            child: header
                ? Text(completed, style: style)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          color: AppColors.secondary,
                          backgroundColor: AppColors.mutedSurface,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(completed, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
