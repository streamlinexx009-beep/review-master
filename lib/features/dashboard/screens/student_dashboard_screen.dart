import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _HeroAndHighlights(),
          SizedBox(height: 24),
          _MetricsGrid(),
          SizedBox(height: 34),
          _SectionHeader(
            title: 'Upcoming class',
            subtitle: 'Today, you have 3 upcoming class',
            action: 'More',
          ),
          SizedBox(height: 18),
          _UpcomingClassList(),
          SizedBox(height: 34),
          _ClassroomSection(),
        ],
      ),
    );
  }
}

class _HeroAndHighlights extends StatelessWidget {
  const _HeroAndHighlights();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final hero = const _WelcomeHero();
        final highlights = const _HighlightColumn();

        if (compact) {
          return Column(
            children: [
              hero,
              const SizedBox(height: 16),
              highlights,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: hero),
            const SizedBox(width: 18),
            Expanded(flex: 4, child: highlights),
          ],
        );
      },
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 218),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x220F9F9A), blurRadius: 24, offset: Offset(0, 14)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -34,
            child: Icon(Icons.auto_stories_rounded, size: 160, color: Colors.white.withValues(alpha: .12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '75% weekly activity',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Hi, Review Master! 👋',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have a strong learning streak this week. Keep your classes, exams, and review sessions moving.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .88)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: const [
                  _HeroChip(icon: Icons.menu_book_rounded, label: '3 upcoming classes'),
                  _HeroChip(icon: Icons.quiz_rounded, label: '2 exams ready'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text)),
        ],
      ),
    );
  }
}

class _HighlightColumn extends StatelessWidget {
  const _HighlightColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Expanded(
          child: _HighlightCard(
            icon: Icons.calendar_today_rounded,
            title: 'Today schedule',
            subtitle: '01 Aug 2026 • 3 classes',
            accent: AppColors.secondary,
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: _HighlightCard(
            icon: Icons.emoji_events_rounded,
            title: 'Learning goal',
            subtitle: 'Complete 9 of 16 activities',
            accent: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 1180
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
          childAspectRatio: count == 1 ? 3.1 : 2.25,
          children: const [
            _MetricCard(title: 'Total class', value: '100', trend: '15%', positive: true, variant: _MetricVariant.bars),
            _MetricCard(title: 'Total students', value: '124', trend: '10%', positive: true, variant: _MetricVariant.line),
            _MetricCard(title: 'Gross score', value: '91%', trend: '10%', positive: false, variant: _MetricVariant.profit),
            _MetricCard(title: 'Total visits', value: '248k', trend: '25%', positive: true, variant: _MetricVariant.bars),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;

  const _SectionHeader({required this.title, required this.subtitle, required this.action});

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
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _TrendPill(trend: trend, positive: positive),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 72, height: 76, child: _MiniChart(variant: variant, positive: positive)),
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
            _ChartBar(height: 28, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 24, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 40, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 34, color: AppColors.error),
          ],
        );
      case _MetricVariant.bars:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const _ChartBar(height: 44, color: Color(0xFFF0F2F5)),
            const _ChartBar(height: 34, color: Color(0xFFF0F2F5)),
            _ChartBar(height: 60, color: positive ? AppColors.primary : AppColors.error),
            const _ChartBar(height: 48, color: Color(0xFFF0F2F5)),
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
      width: 12,
      height: height,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
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

class _UpcomingClassList extends StatelessWidget {
  const _UpcomingClassList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
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
    );
  }
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
      width: 370,
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: highlighted ? Colors.transparent : AppColors.border),
        boxShadow: highlighted
            ? const [BoxShadow(color: Color(0x330F9F9A), blurRadius: 22, offset: Offset(0, 12))]
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: highlighted ? Colors.white.withValues(alpha: .16) : AppColors.mutedSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(time, style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: foreground, fontWeight: FontWeight.w900, height: 1.25),
          ),
          const Spacer(),
          Row(
            children: [
              Flexible(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: highlighted ? AppColors.secondary : Colors.transparent,
                    foregroundColor: highlighted ? Colors.white : AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: FittedBox(child: Text(buttonText)),
                ),
              ),
              const SizedBox(width: 12),
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
      width: 86,
      height: 32,
      child: Stack(
        children: const [
          _SmallAvatar(left: 0, color: Color(0xFFFFD4BA)),
          _SmallAvatar(left: 20, color: Color(0xFFECC7B8)),
          _SmallAvatar(left: 40, color: Color(0xFFBFE3DD)),
          Positioned(
            left: 60,
            child: CircleAvatar(
              radius: 15,
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
        radius: 15,
        backgroundColor: Colors.white,
        child: CircleAvatar(radius: 13, backgroundColor: color, child: const Icon(Icons.person, size: 14, color: AppColors.text)),
      ),
    );
  }
}

class _ClassroomSection extends StatelessWidget {
  const _ClassroomSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ClassroomHeader(),
        SizedBox(height: 18),
        _ClassroomList(),
      ],
    );
  }
}

class _ClassroomHeader extends StatelessWidget {
  const _ClassroomHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final filters = Wrap(
          spacing: 14,
          runSpacing: 12,
          children: const [
            _FilterButton(label: 'All category'),
            _FilterButton(label: 'All status'),
          ],
        );

        final search = SizedBox(
          width: compact ? double.infinity : 260,
          height: 50,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search class',
              prefixIcon: const Icon(Icons.search_rounded),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Classroom', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              filters,
              const SizedBox(height: 12),
              search,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Classroom', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            Row(children: [Expanded(child: filters), search]),
          ],
        );
      },
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

class _ClassroomList extends StatelessWidget {
  const _ClassroomList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ClassroomRow(title: 'UI/UX fundamental', category: 'UI/UX', duration: '14 Hours', status: 'In progress', completed: '9/16 Completed', progress: .72),
        SizedBox(height: 12),
        _ClassroomRow(title: 'Anatomy mastery review', category: 'Science', duration: '10 Hours', status: 'Upcoming', completed: '4/12 Completed', progress: .34),
        SizedBox(height: 12),
        _ClassroomRow(title: 'Pharmacology drills', category: 'Health', duration: '18 Hours', status: 'Completed', completed: '20/20 Completed', progress: 1),
      ],
    );
  }
}

class _ClassroomRow extends StatelessWidget {
  final String title;
  final String category;
  final String duration;
  final String status;
  final String completed;
  final double progress;

  const _ClassroomRow({
    required this.title,
    required this.category,
    required this.duration,
    required this.status,
    required this.completed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 840;
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClassTitle(title: title),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 18,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _InfoPill(label: 'Category', value: category),
                      _InfoPill(label: 'Duration', value: duration),
                      _StatusPill(status: status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProgressBlock(completed: completed, progress: progress),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: _ClassTitle(title: title)),
                const SizedBox(width: 12),
                const SizedBox(width: 92, child: _AvatarStack()),
                const SizedBox(width: 12),
                Expanded(child: Text(category, overflow: TextOverflow.ellipsis)),
                Expanded(child: Text(duration, overflow: TextOverflow.ellipsis)),
                SizedBox(width: 140, child: _StatusPill(status: status)),
                const SizedBox(width: 16),
                SizedBox(width: 180, child: _ProgressBlock(completed: completed, progress: progress)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClassTitle extends StatelessWidget {
  final String title;
  const _ClassTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (_) {}),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(color: AppColors.textMuted)),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: status == 'In progress' ? AppColors.secondarySoft : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(status, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  final String completed;
  final double progress;

  const _ProgressBlock({required this.completed, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: progress, minHeight: 7, color: AppColors.secondary, backgroundColor: AppColors.mutedSurface),
        ),
        const SizedBox(height: 7),
        Text(completed, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
