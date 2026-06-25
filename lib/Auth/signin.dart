import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GaitAI/Auth/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:GaitAI/home/home.dart';

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
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A6FD4)),
//       ),
//       home: const SignInPage(),
//     );
//   }
// }

const kPrimary = Color(0xFF1A6FD4);
const kPrimaryDark = Color(0xFF0A3D8F);
const kAccent = Color(0xFF00C9FF);
const kBg = Color(0xFFF5F8FF);
const kSurface = Color.fromARGB(255, 255, 255, 255);
const kCard = Color.fromARGB(255, 255, 255, 255);
const kBorder = Color.fromARGB(57, 121, 195, 248);

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  late AnimationController _nebulaCtrl; // slow background drift
  late AnimationController _gridCtrl; // scanning grid line
  late AnimationController _entryCtrl; // staggered entry
  late AnimationController _btnCtrl; // button pulse
  late AnimationController _errorCtrl; // shake on error
  late AnimationController _successCtrl; // success burst

  late Animation<double> _nebula;
  late Animation<double> _grid;
  late Animation<double> _logoAnim;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardOpacity;
  late Animation<double> _btnPulse;
  late Animation<double> _shake;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;

  final _formKey = GlobalKey<FormState>();
  
  bool _obscure = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _showSuccess = false;
  String? _focusedField;

  @override
  void initState() {
    super.initState();

    _nebulaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _gridCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _errorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _nebula = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _nebulaCtrl, curve: Curves.linear));

    _grid = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _gridCtrl, curve: Curves.easeInOut));

    _logoAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.65), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.28, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.28, 0.72, curve: Curves.easeIn),
      ),
    );

    _btnPulse = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _errorCtrl, curve: Curves.easeInOut));

    _successScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut));
    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();


  Future SignIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );
  }

  @override
  void dispose() {
    _nebulaCtrl.dispose();
    _gridCtrl.dispose();
    _entryCtrl.dispose();
    _btnCtrl.dispose();
    _errorCtrl.dispose();
    _successCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) {
    _errorCtrl.forward(from: 0);
    HapticFeedback.heavyImpact();
    return;
  }
  setState(() => _isLoading = true);
  try {
    await SignIn(); // ← كال Firebase فعلاً
    if (!mounted) return;
    setState(() { _isLoading = false; _showSuccess = true; });
    _successCtrl.forward();
  } catch (e) {
    setState(() => _isLoading = false);
    _errorCtrl.forward(from: 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Deep space background ──
          AnimatedBuilder(
            animation: Listenable.merge([_nebula, _grid]),
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _NebulaPainter(nebula: _nebula.value, grid: _grid.value),
            ),
          ),

          // ── Floating stars ──
          AnimatedBuilder(
            animation: _nebula,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _StarsPainter(progress: _nebulaCtrl.value),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: _showSuccess ? _buildSuccess(size) : _buildMain(size),
          ),
        ],
      ),
    );
  }

  Widget _buildMain(Size size) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 28),

          // ── Logo hero ──
          AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, __) => FadeTransition(
              opacity: _logoOpacity,
              child: Transform.scale(
                scale: _logoAnim.value,
                child: _buildHero(),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── Card ──
          AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, __) => SlideTransition(
              position: _cardSlide,
              child: FadeTransition(
                opacity: _cardOpacity,
                child: AnimatedBuilder(
                  animation: _shake,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(_shake.value, 0),
                    child: _buildCard(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Bottom links ──
          FadeTransition(opacity: _cardOpacity, child: _buildBottom()),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        // Glowing icon
        Stack(
          alignment: Alignment.center,
          children: [
            // outer glow ring
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kAccent.withOpacity(0.18), Colors.transparent],
                ),
              ),
            ),
            // inner ring
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kAccent.withOpacity(0.3), width: 1.5),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 25, 197, 206),
                    Color.fromARGB(255, 11, 121, 255),
                  ],
                ),
              ),
            ),
            // icon
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(r),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 34,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [Color.fromARGB(255, 19, 40, 104), kAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(r),
          child: const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Sign in to continue your gait analysis',
          style: TextStyle(
            fontSize: 14,
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.45),
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 24),

        // Social buttons
        Row(
          children: [
            Expanded(
              child: _DarkSocialBtn(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                iconColor: const Color(0xFFEA4335),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DarkSocialBtn(
                label: 'Apple',
                icon: Icons.apple_rounded,
                iconColor: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                thickness: 1.2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or sign in with email',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                thickness: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color.fromARGB(214, 255, 255, 255),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: kPrimary.withOpacity(0.08),
            blurRadius: 60,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email
            _DarkField(
              label: 'Email Address',

              hint: 'Your@example.com',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onFocusChange: (f) =>
                  setState(() => _focusedField = f ? 'email' : null),
              isFocused: _focusedField == 'email',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Password
            _DarkField(
              label: 'Password',
              hint: '••••••••',
              controller: _passCtrl,
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              onFocusChange: (f) =>
                  setState(() => _focusedField = f ? 'pass' : null),
              isFocused: _focusedField == 'pass',
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color.fromARGB(255, 57, 57, 57).withOpacity(0.3),
                  size: 20,
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Password is too short' : null,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _rememberMe ? kPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _rememberMe ? kPrimary : kBorder,
                            width: 1.8,
                          ),
                        ),
                        child: _rememberMe
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 13,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => _showForgotSheet(),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: kPrimary.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // Sign In button
            AnimatedBuilder(
              animation: _btnPulse,
              builder: (_, __) => Transform.scale(
                scale: _isLoading ? 1.0 : _btnPulse.value,
                child: _SignInButton( onTap: _submit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );
              },
              child: const Text(
                'Create Account',
                style: TextStyle(
                  color: kAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Forgot Password Sheet ────────────────────────────────────
  void _showForgotSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ForgotPasswordSheet(),
    );
  }

  Widget _buildSuccess(Size size) {
    return AnimatedBuilder(
      animation: _successCtrl,
      builder: (_, __) => FadeTransition(
        opacity: _successOpacity,
        child: Transform.scale(
          scale: _successScale.value,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated success ring
                  _SuccessRing(),

                  const SizedBox(height: 32),

                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [Color.fromARGB(255, 30, 0, 164), kAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(r),
                    child: const Text(
                      'You\'re In!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 12, 128, 217),
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Welcome back. Your gait data\nis ready for analysis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: const Color.fromARGB(255, 15, 42, 176).withOpacity(0.5),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MainShell()),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimary, kAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.5),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Go Inside!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final void Function(bool)? onFocusChange;
  final bool isFocused;
  final String? Function(String?)? validator;

  const _DarkField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onFocusChange,
    this.isFocused = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: isFocused
                ? kPrimary
                : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
          ),
          child: Text(label.toUpperCase()),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: onFocusChange,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: isFocused
                  ? const Color.fromARGB(75, 255, 255, 255)
                  : const Color.fromARGB(40, 217, 216, 216).withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFocused ? kPrimary : kBorder,
                width: isFocused ? 1.8 : 1.2,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D1B2A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color.fromARGB(255, 69, 69, 69).withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    icon,
                    color: isFocused
                        ? Color(0xFF1A6FD4)
                        : const Color.fromARGB(
                            255,
                            42,
                            42,
                            42,
                          ).withOpacity(0.6),
                    size: 20,
                  ),
                ),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 16,
                ),
                errorStyle: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignInButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SignInButton({ required this.onTap});

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Animation<double> _sh;

  // final _emailCtrl = TextEditingController();
  // final _passCtrl = TextEditingController();


  // Future SignIn() async {
  //   await FirebaseAuth.instance.signInWithEmailAndPassword(
  //     email: _emailCtrl.text.trim(),
  //     password: _passCtrl.text.trim(),
  //   );
  // }

  // @override
  // dispose() {
  //   _emailCtrl.dispose();
  //   _passCtrl.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _sh = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut));
  }

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _sh,
        builder: (_, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                    colors: [kPrimary, kAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
            border: Border.all(
              color: Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
               const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BiometricButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BiometricButton({required this.onTap});

  @override
  State<_BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<_BiometricButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _ring = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ring,
        builder: (_, __) => Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _DarkSocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  const _DarkSocialBtn({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(103, 165, 163, 163).withOpacity(0.35),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordSheet extends StatefulWidget {
  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _sent = false;
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_ctrl.text.contains('@')) {
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _sent = true);
      _anim.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: _sent
          ? AnimatedBuilder(
              animation: _scale,
              builder: (_, __) => Transform.scale(
                scale: _scale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [kPrimary, kAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Check your inbox!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A reset link has been sent to\n${_ctrl.text}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPrimary, kAccent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your email and we\'ll send a reset link',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder, width: 1.3),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'your@email.com',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ).withOpacity(0.2),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ).withOpacity(0.25),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kAccent],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Send Reset Link',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SuccessRing extends StatefulWidget {
  @override
  State<_SuccessRing> createState() => _SuccessRingState();
}

class _SuccessRingState extends State<_SuccessRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _arc;
  late Animation<double> _check;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _arc = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _check = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.55, 1.0, curve: Curves.elasticOut),
      ),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(120, 120),
              painter: _ArcPainter(progress: _arc.value),
            ),
            Transform.scale(
              scale: _check.value,
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [kPrimary, kAccent],
                ).createShader(r),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // BG ring
    final bgPaint = Paint()
      ..color = kBorder
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [kPrimary, kAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

class _NebulaPainter extends CustomPainter {
  final double nebula;
  final double grid;
  _NebulaPainter({required this.nebula, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep nebula blob 1 — top right
    final p1 = Paint()
      ..shader =
          RadialGradient(
            colors: [kPrimary.withOpacity(0.22), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * 0.85 + math.cos(nebula * 0.18) * 28,
                size.height * 0.08 + math.sin(nebula * 0.18) * 20,
              ),
              radius: size.width * 0.7,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08),
      size.width * 0.7,
      p1,
    );

    // Nebula blob 2 — bottom left
    final p2 = Paint()
      ..shader =
          RadialGradient(
            colors: [kAccent.withOpacity(0.10), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * 0.08 + math.sin(nebula * 0.14) * 22,
                size.height * 0.82 + math.cos(nebula * 0.14) * 22,
              ),
              radius: size.width * 0.6,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.82),
      size.width * 0.6,
      p2,
    );

    // Scanning line
    final scanY = grid * size.height;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          kAccent.withOpacity(0.08),
          kAccent.withOpacity(0.18),
          kAccent.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, scanY - 2, size.width, 4));
    canvas.drawRect(Rect.fromLTWH(0, scanY - 2, size.width, 4), scanPaint);

    // Grid dots
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    const spacing = 30.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }

    // Diagonal accent lines
    final linePaint = Paint()
      ..color = kPrimary.withOpacity(0.05)
      ..strokeWidth = 1;
    for (int i = -5; i < 15; i++) {
      final x = i * 60.0 + math.sin(nebula * 0.08) * 10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.4, size.height * 0.4),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_NebulaPainter old) =>
      old.nebula != nebula || old.grid != grid;
}

class _StarsPainter extends CustomPainter {
  final double progress;
  _StarsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(77);
    for (int i = 0; i < 55; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.6 + rng.nextDouble() * 1.4;
      final phase = rng.nextDouble();
      final twinkle = (math.sin((progress + phase) * 2 * math.pi) * 0.5 + 0.5);
      final opacity = 0.08 + twinkle * 0.22;
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}

