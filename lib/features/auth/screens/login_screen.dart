import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Container(
                padding: const EdgeInsets.fromLTRB(44, 32, 44, 44),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 36,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const _LandingNav(),
                    const SizedBox(height: 56),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 920;

                        return Flex(
                          direction: wide ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: wide ? 6 : 0,
                              child: const _HeroContent(),
                            ),
                            SizedBox(width: wide ? 42 : 0, height: wide ? 0 : 34),
                            Expanded(
                              flex: wide ? 4 : 0,
                              child: const _SignInPanel(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 46),
                    const _LearningIllustration(),
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

class _LandingNav extends StatelessWidget {
  const _LandingNav();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LogoGlyph(),
        const SizedBox(width: 12),
        Text(
          'ReviewHub',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        const Spacer(),
        if (MediaQuery.of(context).size.width > 820) ...const [
          _NavText('Product'),
          _NavText('Solutions'),
          _NavText('Pricing'),
          _NavText('Contact'),
          _NavText('Blog'),
          SizedBox(width: 18),
        ],
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Sign In'),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('Get Started'),
        ),
      ],
    );
  }
}

class _NavText extends StatelessWidget {
  final String text;

  const _NavText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Built for '),
              TextSpan(
                text: 'Review Centers,\n',
                style: TextStyle(color: AppColors.primary),
              ),
              const TextSpan(text: 'loved by learners'),
            ],
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.08,
                letterSpacing: -1.4,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Plan classes, upload learning materials, run exams, track mastery, and keep every student moving toward better outcomes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 30),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            minimumSize: const Size(220, 58),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Text('Get Started'),
        ),
      ],
    );
  }
}

class _SignInPanel extends StatelessWidget {
  const _SignInPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue to your classroom dashboard.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 26),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}

class _LearningIllustration extends StatelessWidget {
  const _LearningIllustration();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        return Flex(
          direction: compact ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              flex: compact ? 0 : 6,
              child: const _BrowserMockup(),
            ),
            SizedBox(width: compact ? 0 : 20, height: compact ? 20 : 0),
            Expanded(
              flex: compact ? 0 : 3,
              child: const _LessonListMockup(),
            ),
            SizedBox(width: compact ? 0 : 20, height: compact ? 20 : 0),
            Expanded(
              flex: compact ? 0 : 3,
              child: const _FamilyCardMockup(),
            ),
          ],
        );
      },
    );
  }
}

class _BrowserMockup extends StatelessWidget {
  const _BrowserMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7D9),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.fromLTRB(56, 48, 0, 0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(22)),
        ),
        child: Column(
          children: [
            Container(
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(22)),
              ),
              child: Center(
                child: Container(
                  width: 260,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _MiniAvatar(index: index),
                      ),
                    ),
                    const Spacer(),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(width: 70, height: 10, decoration: _barDecoration()),
                            const SizedBox(width: 18),
                            Expanded(child: Container(height: 10, decoration: _barDecoration())),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonListMockup extends StatelessWidget {
  const _LessonListMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6DFF2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: Row(
              children: [
                _MiniAvatar(index: index),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.54),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyCardMockup extends StatelessWidget {
  const _FamilyCardMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4C7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(child: Container(height: 18, decoration: _barDecoration(color: const Color(0xFFE9B883)))),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(Icons.auto_stories_rounded, size: 76, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _barDecoration({Color color = const Color(0xFFE8ECF1)}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(999),
  );
}

class _MiniAvatar extends StatelessWidget {
  final int index;

  const _MiniAvatar({required this.index});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFFFC857),
      Color(0xFF7BD389),
      Color(0xFF9D7FEA),
      Color(0xFFFF8A3D),
      Color(0xFF4BC0C8),
      Color(0xFFB8D8FF),
    ];

    return CircleAvatar(
      radius: 15,
      backgroundColor: colors[index % colors.length],
      child: const Icon(Icons.star_rounded, color: Colors.white, size: 15),
    );
  }
}

class _LogoGlyph extends StatelessWidget {
  const _LogoGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        children: [
          _LogoBlock(left: 0, top: 0, color: AppColors.primary),
          _LogoBlock(left: 16, top: 0, color: AppColors.secondary),
          _LogoBlock(left: 0, top: 16, color: AppColors.primaryDark),
          _LogoBlock(left: 16, top: 16, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  final double left;
  final double top;
  final Color color;

  const _LogoBlock({
    required this.left,
    required this.top,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
