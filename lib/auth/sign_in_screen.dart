import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import '../auth_service.dart';
import '../main.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/IAQuick_icon.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Image.asset(
                'assets/IAQuick_full_logo.png',
                height: 100,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      try {
                        final cred = await authService.signIn(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        if (cred.user != null && mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (_) => false,
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          _error = e.message;
                        });
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  final cred = await authService.signInWithGoogle();
                  if (cred.user != null && mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                      (_) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _error = e.message;
                  });
                }
              },
              child: const Text('Sign In with Google'),
            ),
            if (Platform.isIOS) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final cred = await authService.signInWithApple();
                    if (cred.user != null && mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                        (_) => false,
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      _error = e.message;
                    });
                  }
                },
                child: const Text('Sign In with Apple'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
