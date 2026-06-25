import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GaitAI/Auth/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:GaitAI/home/home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  late AnimationController _bgAnim;
  late AnimationController _entryAnim;
  late AnimationController _successAnim;
  late AnimationController _waveAnim;
  late AnimationController _orbAnim;

  late Animation<double> _bgRot;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _formOpacity;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;
  late Animation<double> _wave;
  late Animation<double> _orb;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  Future Signup() async {
    UserCredential userCredential = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
      email: _emailCtrl.text.trim(), 
      password: _passwordCtrl.text.trim(),
    );
    await userCredential.user?.updateDisplayName(_nameCtrl.text.trim());
  }

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;
  bool _showSuccess = false;

  String? _focusedField;

  int _passStrength = 0;

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _entryAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _orbAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _bgRot = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _bgAnim, curve: Curves.linear));

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryAnim,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryAnim,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _formSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryAnim,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryAnim,
        curve: const Interval(0.3, 0.75, curve: Curves.easeIn),
      ),
    );

    _successScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut));

    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnim,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _wave = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveAnim, curve: Curves.linear));

    _orb = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _orbAnim, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entryAnim.forward();
    });
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _entryAnim.dispose();
    _successAnim.dispose();
    _waveAnim.dispose();
    _orbAnim.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String val) {
    int strength = 0;
    if (val.length >= 6) strength++;
    if (val.length >= 10) strength++;
    if (val.contains(RegExp(r'[A-Z]'))) strength++;
    if (val.contains(RegExp(r'[0-9!@#\$%^&*]'))) strength++;
    setState(() => _passStrength = strength);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnack('Please agree to Terms & Privacy Policy');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await Signup();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
      _successAnim.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A6FD4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static const Color _primary = Color(0xFF1A6FD4);

  static const Color _accent = Color(0xFF00C9FF);
  static const Color _bg = Color(0xFFF5F8FF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_bgRot, _orb]),
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _SignUpBgPainter(
                rotation: _bgRot.value,
                orb: _orb.value,
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _wave,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _WaveTopPainter(wave: _wave.value),
            ),
          ),

          SafeArea(
            child: _showSuccess
                ? _buildSuccessState(size)
                : _buildFormState(size),
          ),
        ],
      ),
    );
  }

  Widget _buildFormState(Size size) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Logo + Header ──
            AnimatedBuilder(
              animation: _entryAnim,
              builder: (_, __) => FadeTransition(
                opacity: _logoOpacity,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: _buildHeader(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Form Card ──
            AnimatedBuilder(
              animation: _entryAnim,
              builder: (_, __) => SlideTransition(
                position: _formSlide,
                child: FadeTransition(
                  opacity: _formOpacity,
                  child: _buildFormCard(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            AnimatedBuilder(
              animation: _formOpacity,
              builder: (_, __) => FadeTransition(
                opacity: _formOpacity,
                child: _buildSignInLink(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'GaitAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Title
        const Text(
          'Create Your\nAccount',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
            height: 1.12,
            letterSpacing: -1.2,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Start your gait health journey today',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 20),

        // Social sign up row
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                color: const Color(0xFFEA4335),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                icon: Icons.apple_rounded,
                color: Colors.black,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.grey.shade200, thickness: 1.5),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.grey.shade200, thickness: 1.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            _AnimatedField(
              label: 'Full Name',
              hint: 'Your Name',
              controller: _nameCtrl,
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              onFocusChange: (f) =>
                  setState(() => _focusedField = f ? 'name' : null),
              isFocused: _focusedField == 'name',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your name';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email
            _AnimatedField(
              label: 'Email Address',
              hint: 'Your@example.com',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onFocusChange: (f) =>
                  setState(() => _focusedField = f ? 'email' : null),
              isFocused: _focusedField == 'email',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password
            _AnimatedField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordCtrl,
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePass,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
              onFocusChange: (f) =>
                  setState(() => _focusedField = f ? 'pass' : null),
              isFocused: _focusedField == 'pass',
              onChanged: _checkPasswordStrength,
              validator: (v) => (v == null || v.length < 6)
                  ? 'Password must be at least 6 characters'
                  : null,
            ),

            if (_passwordCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              _PasswordStrengthBar(strength: _passStrength),
            ],

            const SizedBox(height: 16),

            _AnimatedField(
              label: 'Confirm Password',
              hint: '••••••••',
              controller: _confirmCtrl,
              icon: Icons.lock_outline_rounded,
              obscure: _obscureConfirm,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
              onFocusChange: (f) =>
                  setState(() => _focusedField = f ? 'confirm' : null),
              isFocused: _focusedField == 'confirm',
              validator: (v) =>
                  v != _passwordCtrl.text ? 'Passwords do not match' : null,
            ),

            const SizedBox(height: 20),

            // Submit button
            _SubmitButton(
              isLoading: _isLoading,
              onTap: _submit,
              accentColor: _primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInPage()),
            );
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: _primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(Size size) {
    return AnimatedBuilder(
      animation: _successAnim,
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
                  // Animated check circle
                  _SuccessCircle(),

                  const SizedBox(height: 32),

                  const Text(
                    'Welcome to\nGaitAI! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1B2A),
                      height: 1.15,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Your account has been created successfully.\nLet\'s start analyzing your gait.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Stats preview row
                  _StatsPreviewRow(),

                  const SizedBox(height: 40),

                  // Continue button
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
                          colors: [Color(0xFF1A6FD4), Color(0xFF00C9FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1A6FD4).withOpacity(0.5),
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

class _AnimatedField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final void Function(bool)? onFocusChange;
  final bool isFocused;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const _AnimatedField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onFocusChange,
    this.isFocused = false,
    this.onChanged,
    this.validator,
  });

  static const Color _primary = Color(0xFF1A6FD4);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isFocused ? _primary : const Color(0xFF6B7280),
            letterSpacing: 0.3,
          ),
          child: Text(label.toUpperCase()),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: onFocusChange,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: isFocused ? Colors.white : const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFocused ? _primary : const Color(0xFFE8EEFF),
                width: isFocused ? 2.0 : 1.5,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: _primary.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              onChanged: onChanged,
              validator: validator,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D1B2A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    icon,
                    color: isFocused ? _primary : Colors.grey.shade400,
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

class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0-4

  const _PasswordStrengthBar({required this.strength});

  String get _label {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  Color get _color {
    switch (strength) {
      case 0:
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF3B82F6);
      case 4:
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(4, (i) {
              final filled = i < strength;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? _color : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _color,
              ),
              child: Text(_label),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Color accentColor;

  const _SubmitButton({
    required this.isLoading,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmer = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (_, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [Colors.grey.shade300, Colors.grey.shade300]
                  : [widget.accentColor, const Color(0xFF00C9FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: widget.isLoading
                ? []
                : [
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
              if (!widget.isLoading)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CustomPaint(
                      painter: _ShimmerPainter(progress: _shimmer.value),
                    ),
                  ),
                ),
              widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
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

class _ShimmerPainter extends CustomPainter {
  final double progress;
  _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.18),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(
              progress * size.width - size.width * 0.5,
              0,
              size.width * 0.5,
              size.height,
            ),
          );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCircle extends StatefulWidget {
  @override
  State<_SuccessCircle> createState() => _SuccessCircleState();
}

class _SuccessCircleState extends State<_SuccessCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  // ignore: unused_field
  late Animation<double> _ring;
  late Animation<double> _check;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ring = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _check = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Transform.scale(
          scale: _check.value,
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  STATS PREVIEW ROW (shown after success)
// ══════════════════════════════════════════════════════════════
class _StatsPreviewRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      ('👟', 'Gait\nTracking'),
      ('📊', 'Smart\nAnalysis'),
      ('🛡️', 'Fall\nPrevention'),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: item == items.first ? 0 : 8,
              right: item == items.last ? 0 : 8,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF1A6FD4).withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SignUpBgPainter extends CustomPainter {
  final double rotation;
  final double orb;

  _SignUpBgPainter({required this.rotation, required this.orb});

  @override
  void paint(Canvas canvas, Size size) {
    const primary = Color(0xFF1A6FD4);
    const accent = Color(0xFF00C9FF);

    // Top right blob
    final p1 = Paint()
      ..shader =
          RadialGradient(
            colors: [primary.withOpacity(0.10), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * 0.9 + math.cos(rotation * 0.25) * 25,
                size.height * 0.05 + math.sin(rotation * 0.25) * 18,
              ),
              radius: size.width * 0.6,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.05),
      size.width * 0.6,
      p1,
    );

    // Bottom left blob
    final p2 = Paint()
      ..shader =
          RadialGradient(
            colors: [accent.withOpacity(0.08), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * 0.05 + math.sin(rotation * 0.2) * 20,
                size.height * 0.85 + math.cos(rotation * 0.2) * 20,
              ),
              radius: size.width * 0.55,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * 0.85),
      size.width * 0.55,
      p2,
    );

    // Floating orb
    final orbX = size.width * 0.5 + math.cos(rotation * 0.15) * 60;
    final orbY = size.height * (0.15 + orb * 0.05);
    final p3 = Paint()
      ..color = primary.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(Offset(orbX, orbY), size.width * 0.25, p3);

    // Subtle dots grid
    final dotPaint = Paint()
      ..color = primary.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    const spacing = 32.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height * 0.45; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignUpBgPainter old) =>
      old.rotation != rotation || old.orb != orb;
}

class _WaveTopPainter extends CustomPainter {
  final double wave;
  _WaveTopPainter({required this.wave});

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF1A6FD4);
    final paint = Paint()
      ..color = color.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.12);

    for (double x = size.width; x >= 0; x -= 1) {
      final y =
          size.height * 0.12 +
          math.sin((x / size.width * 2 * math.pi) + wave) * 12 +
          math.sin((x / size.width * 4 * math.pi) + wave * 1.3) * 6;
      path.lineTo(x, y);
    }

    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveTopPainter old) => old.wave != wave;
}
