import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../services/firebase_service.dart';

/// Spotify-like Theme
class AppTheme {
  static const Color bg = Color(0xFF121212);
  static const Color card = Color(0xFF000000);
  static const Color onBg = Colors.white;
  static const Color muted = Color(0xFFB3B3B3);
  static const Color brand = Color(0xFF1DB954);

  // Brand Colors
  static const Color fbBlue = Color(0xFF1877F2);
  static const Color googleRed = Color(0xFFDB4437);
  static const Color appleBlack = Colors.white; // Apple icon is white

  static const double radius = 16;
  static const double columnMax = 420;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true; // keep toggle text behavior
  bool _obscure = true;
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.columnMax),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogo(),
        const SizedBox(height: 16),
        const _CardTitle(),
        const SizedBox(height: 18),
        _buildSocialButtons(),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
        _buildForm(),
        const SizedBox(height: 16),
        _buildToggleRow(),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Top brand row (uses your asset if available)
  Widget _buildLogo() {
    return Column(
      children: [
        // Try to load your asset; if it fails, show a simple placeholder icon.
        SizedBox(
          height: 190,
          child: Image.asset('assets/spotify_logo.png', fit: BoxFit.contain),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _socialButton(
          label: 'Continue with Facebook',
          icon: FontAwesomeIcons.facebookF,
          iconColor: Color(0xFF1877F2), // Facebook Blue
          textColor: Colors.white,
          onPressed: () => _showSnack('Facebook sign-in not implemented'),
        ),
        const SizedBox(height: 12),
        _socialButton(
          label: 'Continue with Google',
          icon: FontAwesomeIcons.google,
          iconColor: Colors.white, // We'll make Google multicolor below
          textColor: Colors.white,
          isGoogle: true, // Special flag for Google multicolor
          onPressed: () => _showSnack('Google sign-in not implemented'),
        ),
        const SizedBox(height: 12),
        _socialButton(
          label: 'Continue with Apple',
          icon: FontAwesomeIcons.apple,
          iconColor: Colors.white,
          textColor: Colors.white,
          onPressed: () => _showSnack('Apple sign-in not implemented'),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.white12)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white12)),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            controller: _emailController,
            label: 'Email or username',
            hint: 'Email or username',
            icon: FontAwesomeIcons.solidEnvelope,
            validator: _validateEmailOrUsername,
            useLabelAsPlaceholder: true,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _passwordController,
            label: 'Password',
            hint: 'Password',
            icon: FontAwesomeIcons.lock,
            obscure: _obscure,
            toggle: () => setState(() => _obscure = !_obscure),
            validator: _validatePassword,
            useLabelAsPlaceholder: true,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _showSnack('Reset flow not implemented'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(top: 6, left: 0, right: 0),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Reset Password',
                style: TextStyle(color: AppTheme.onBg),
              ),
            ),
          ),
          const SizedBox(height: 2),
          _rememberRow(),
          const SizedBox(height: 14),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _PrimaryButton(label: 'LOG IN', onTap: _submit),
        ],
      ),
    );
  }

  Widget _rememberRow() {
    return Row(
      children: [
        Switch.adaptive(
          value: _rememberMe,
          onChanged: (v) => setState(() => _rememberMe = v),
          activeColor: Colors.white,
          activeTrackColor: AppTheme.brand,
          inactiveThumbColor: Colors.white70,
          inactiveTrackColor: Colors.white24,
        ),
        const SizedBox(width: 8),
        const Text('Remember me', style: TextStyle(color: AppTheme.onBg)),
      ],
    );
  }

  Widget _buildToggleRow() {
    return TextButton(
      onPressed: () => setState(() => _isLogin = !_isLogin),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Text(
          _isLogin
              ? "Don't have an account? SIGN UP"
              : 'Already have an account? LOG IN',
          key: ValueKey(_isLogin),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.onBg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ====== Validation & Submit ======
  String? _validateEmailOrUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email or username';
    }
    if (value.contains('@') &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
    // usernames are accepted as-is
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final firebaseService = context.read<FirebaseService>();
    final emailOrUsername = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // NOTE: If you truly support username login, adapt your auth call here.
    final error = _isLogin
        ? await firebaseService.signIn(emailOrUsername, password)
        : await firebaseService.signUp(emailOrUsername, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showSnack(
      error ?? (_isLogin ? 'Welcome back!' : 'Account created successfully!'),
      success: error == null,
    );
  }

  void _showSnack(String message, {bool success = false}) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: success ? 'Success!' : 'Oops!',
        message: message,
        contentType: success ? ContentType.success : ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Card title “Log in”
class _CardTitle extends StatelessWidget {
  const _CardTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Log in',
      textAlign: TextAlign.center,
      style: GoogleFonts.lexend(
        color: const Color.fromARGB(255, 255, 255, 255),
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}

/// Outlined dark social button
Widget _socialButton({
  required String label,
  required IconData icon,
  required Color iconColor,
  required Color textColor,
  required VoidCallback onPressed,
  bool isGoogle = false,
}) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      icon: isGoogle
          ? ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Blue
                    Color(0xFF34A853), // Green
                    Color(0xFFFBBC05), // Yellow
                    Color(0xFFEA4335), // Red
                  ],
                ).createShader(bounds);
              },
              child: Icon(icon, color: Colors.white),
            )
          : Icon(icon, color: iconColor),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white24),
        backgroundColor: Colors.black, // Dark background like Spotify
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
    ),
  );
}

/// Big white pill primary button
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black)),
      ),
    );
  }
}

/// Flat fields with subtle borders (placeholders as labels)
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? toggle;
  final String? Function(String?)? validator;
  final bool useLabelAsPlaceholder;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.obscure = false,
    this.toggle,
    this.validator,
    this.useLabelAsPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppTheme.onBg),
      cursorColor: AppTheme.brand,
      decoration: InputDecoration(
        hintText: useLabelAsPlaceholder ? label : hint,
        labelText: useLabelAsPlaceholder ? null : label,
        prefixIcon: Icon(icon, color: AppTheme.muted, size: 18),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.muted,
                ),
                onPressed: toggle,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF121212),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.white54, width: 1.2),
        ),
      ),
    );
  }
}
