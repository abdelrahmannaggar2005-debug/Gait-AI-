import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:GaitAI/Auth/signup.dart';
import 'Auth/signin.dart';

// void main() {
//   runApp(const GaitAnalysisApp());
// }

// class GaitAnalysisApp extends StatelessWidget {
//   const GaitAnalysisApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'GaitAI',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF1A6FD4),
//           brightness: Brightness.light,
//         ),
//       ),
//       home: const GetStartedPage(),
//     );
//   }
// }

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color secondary;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.secondary,
  });
}

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _heroController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late AnimationController _walkController;
  late AnimationController _particleController;

  late Animation<double> _bgRotation;
  late Animation<double> _heroScale;
  late Animation<double> _heroOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonOpacity;
  late Animation<double> _pulseAnim;
  late Animation<double> _walkAnim;
  late Animation<double> _particleAnim;

  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'AI-Powered\nGait Analysis',
      subtitle:
          'Advanced walking pattern analysis using cutting-edge artificial intelligence technology',
      icon: Icons.directions_walk_rounded,
      accent: const Color(0xFF1A6FD4),
      secondary: const Color(0xFF00C9FF),
    ),
    OnboardingData(
      title: 'Real-Time\nMetrics',
      subtitle:
          'Monitor stride length, cadence, knee angles, and fall risk score instantly',
      icon: Icons.analytics_rounded,
      accent: const Color(0xFF0A4FA0),
      secondary: const Color(0xFF38EFB2),
    ),
    OnboardingData(
      title: 'Your Health,\nPrioritized',
      subtitle:
          'Designed for adults 40+ with clear, accessible results you can understand',
      icon: Icons.favorite_rounded,
      accent: const Color(0xFF1864C8),
      secondary: const Color(0xFFFF6B6B),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _bgRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.linear),
    );

    _heroScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _heroOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _walkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.linear),
    );

    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _heroController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _heroController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _walkController.dispose();
    _particleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _heroController.reset();
    _contentController.reset();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _heroController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgRotation,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: BackgroundPainter(
                rotation: _bgRotation.value,
                accentColor: page.accent,
                secondaryColor: page.secondary,
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _particleAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: ParticlePainter(
                progress: _particleAnim.value,
                color: page.accent,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: page.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.directions_walk_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 400),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: page.accent,
                              letterSpacing: -0.5,
                            ),
                            child: const Text('GaitAI'),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const SignUpPage()
                        ));
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _HeroIllustration(
                        heroScale: _heroScale,
                        heroOpacity: _heroOpacity,
                        pulseAnim: _pulseAnim,
                        walkAnim: _walkAnim,
                        page: _pages[index],
                        size: size,
                      );
                    },
                  ),
                ),

                AnimatedBuilder(
                  animation: _contentController,
                  builder: (_, __) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: page.accent.withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, -8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: List.generate(
                              _pages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                width: i == _currentPage ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: i == _currentPage
                                      ? page.accent
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          SlideTransition(
                            position: _titleSlide,
                            child: FadeTransition(
                              opacity: _titleOpacity,
                              child: Text(
                                page.title,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0D1B2A),
                                  height: 1.15,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Subtitle
                          SlideTransition(
                            position: _subtitleSlide,
                            child: FadeTransition(
                              opacity: _subtitleOpacity,
                              child: Text(
                                page.subtitle,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          SlideTransition(
                            position: _buttonSlide,
                            child: FadeTransition(
                              opacity: _buttonOpacity,
                              child: _currentPage == _pages.length - 1
                                  ? _GetStartedButton(accentColor: page.accent)
                                  : _NextButton(
                                      accentColor: page.accent,
                                      onTap: () {
                                        _pageController.nextPage(
                                          duration: const Duration(
                                              milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _buttonOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const SignInPage()
                          ));
                        },
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: TextStyle(
                            color: page.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double rotation;
  final Color accentColor;
  final Color secondaryColor;

  BackgroundPainter({
    required this.rotation,
    required this.accentColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [accentColor.withOpacity(0.12), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * 0.8 + math.cos(rotation * 0.3) * 30,
          size.height * 0.15 + math.sin(rotation * 0.3) * 20,
        ),
        radius: size.width * 0.65,
      ));
    canvas.drawCircle(
      Offset(
        size.width * 0.8 + math.cos(rotation * 0.3) * 30,
        size.height * 0.15 + math.sin(rotation * 0.3) * 20,
      ),
      size.width * 0.65,
      paint1,
    );

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [secondaryColor.withOpacity(0.10), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * 0.1 + math.cos(rotation * 0.2 + 1) * 25,
          size.height * 0.35 + math.sin(rotation * 0.2 + 1) * 25,
        ),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(
      Offset(
        size.width * 0.1 + math.cos(rotation * 0.2 + 1) * 25,
        size.height * 0.35 + math.sin(rotation * 0.2 + 1) * 25,
      ),
      size.width * 0.5,
      paint2,
    );

    final gridPaint = Paint()
      ..color = accentColor.withOpacity(0.04)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * 0.55), gridPaint);
    }
    for (double y = 0; y < size.height * 0.55; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter old) =>
      old.rotation != rotation || old.accentColor != accentColor;
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (int i = 0; i < 18; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height * 0.55;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final phase = random.nextDouble();
      final radius = 2.0 + random.nextDouble() * 4;
      final opacity = 0.15 + random.nextDouble() * 0.25;

      final t = ((progress + phase) % 1.0) * speed;
      final y = baseY - t * size.height * 0.3;
      final alpha = (math.sin(t * math.pi)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity * alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) =>
      old.progress != progress || old.color != color;
}

class _HeroIllustration extends StatelessWidget {
  final Animation<double> heroScale;
  final Animation<double> heroOpacity;
  final Animation<double> pulseAnim;
  final Animation<double> walkAnim;
  final OnboardingData page;
  final Size size;

  const _HeroIllustration({
    required this.heroScale,
    required this.heroOpacity,
    required this.pulseAnim,
    required this.walkAnim,
    required this.page,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([heroScale, pulseAnim, walkAnim]),
      builder: (_, __) {
        return FadeTransition(
          opacity: heroOpacity,
          child: Center(
            child: Transform.scale(
              scale: heroScale.value,
              child: SizedBox(
                width: size.width * 0.72,
                height: size.width * 0.72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: pulseAnim.value,
                      child: Container(
                        width: size.width * 0.72,
                        height: size.width * 0.72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: page.accent.withOpacity(0.08),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    Transform.scale(
                      scale: 2.0 - pulseAnim.value,
                      child: Container(
                        width: size.width * 0.55,
                        height: size.width * 0.55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: page.accent.withOpacity(0.12),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: size.width * 0.42,
                      height: size.width * 0.42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            page.accent.withOpacity(0.15),
                            page.accent.withOpacity(0.03),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: size.width * 0.30,
                      height: size.width * 0.30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [page.accent, page.secondary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: page.accent.withOpacity(0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        page.icon,
                        color: Colors.white,
                        size: size.width * 0.12,
                      ),
                    ),

                    _buildChip(size, page, '1.2m', 'Stride', -0.6, 0.32),
                    _buildChip(size, page, '98%', 'Symmetry', 0.7, 0.30),
                    _buildChip(size, page, 'LOW', 'Fall Risk',
                        math.pi + 0.4, 0.30),
                    _buildChip(
                        size, page, '4.2', 'km/h', math.pi - 0.5, 0.29),

                    Positioned(
                      bottom: 6,
                      child: _WalkingDots(
                        walkAnim: walkAnim,
                        color: page.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(Size size, OnboardingData page, String label, String sub,
      double angle, double dist) {
    final x = math.cos(angle) * size.width * dist;
    final y = math.sin(angle) * size.width * dist;
    return Transform.translate(
      offset: Offset(x, y),
      child: _MetricChip(label: label, sub: sub, accentColor: page.accent),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String sub;
  final Color accentColor;

  const _MetricChip({
    required this.label,
    required this.sub,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accentColor,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkingDots extends StatelessWidget {
  final Animation<double> walkAnim;
  final Color color;

  const _WalkingDots({required this.walkAnim, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: walkAnim,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final phase = (walkAnim.value - i * 0.2) % 1.0;
            final y = math.sin(phase * math.pi * 2) * 5;
            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.4 + phase * 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GetStartedButton extends StatefulWidget {
  final Color accentColor;
  const _GetStartedButton({required this.accentColor});

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (_, __) {
          return Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accentColor,
                  Color.fromARGB(
                    widget.accentColor.alpha,
                    widget.accentColor.red,
                    widget.accentColor.green,
                    (widget.accentColor.blue + 60).clamp(0, 255),
                  ),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CustomPaint(
                      painter: ShimmerPainter(progress: _shimmerAnim.value),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SignUpPage()
                    ));
                  },
                  borderRadius: BorderRadius.circular(12), // عشان الـ ripple يطلع دائري زي الزر
                  splashColor: Colors.white.withOpacity(0.4),
                  highlightColor: Colors.white.withOpacity(0.2),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                )
                
              ],
            ),
          );
        },
      ),
    );
  }
}

class ShimmerPainter extends CustomPainter {
  final double progress;
  ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
        progress * size.width - size.width * 0.5,
        0,
        size.width * 0.5,
        size.height,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ShimmerPainter old) => old.progress != progress;
}

class _NextButton extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onTap;

  const _NextButton({required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor,
              Color.fromARGB(
                accentColor.alpha,
                accentColor.red,
                accentColor.green,
                (accentColor.blue + 50).clamp(0, 255),
              ),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}