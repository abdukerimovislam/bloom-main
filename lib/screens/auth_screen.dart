// Файл: lib/screens/auth_screen.dart

import 'package:bloom/l10n/app_localizations.dart';
import 'package:bloom/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _googleSignIn() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final error = await _auth.signInWithGoogle();
    if (error != null && mounted) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _guestSignIn() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final error = await _auth.signInAnonymously();
    if (error != null && mounted) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    String? error;
    if (_isLogin) {
      error = await _auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      error = await _auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (mounted) {
      if (error != null) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      }
    }
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                  'assets/lottie/avatar_welcome.json',
                  width: 150,
                  height: 150
              ),
              const SizedBox(height: 20),
              Text(
                _isLogin ? l10n.authLogin : l10n.authRegister,
                style: theme.textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Nunito'
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // --- ИСПРАВЛЕНИЕ: 'const' удален ---
                    icon: FaIcon(FontAwesomeIcons.google, size: 20),
                    // ---
                    label: Text(l10n.authWithGoogle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _googleSignIn,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                    ),
                    onPressed: _guestSignIn,
                    child: Text(l10n.authAsGuest),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(l10n.authOr.toUpperCase(), style: theme.textTheme.labelSmall),
                ),
              ],

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.authEmail,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || !value.contains('@'))
                          ? 'Please enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.authPassword,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Password must be at least 6 characters' : null,
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null && _errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              if (!_isLoading)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitForm,
                    child: Text(_isLogin ? l10n.authLogin : l10n.authRegister),
                  ),
                ),
              TextButton(
                onPressed: _isLoading ? null : _toggleForm,
                child: Text(_isLogin ? l10n.authSwitchToRegister : l10n.authSwitchToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}