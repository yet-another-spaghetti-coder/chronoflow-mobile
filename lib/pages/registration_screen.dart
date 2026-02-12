import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/models/organiser_registration.dart';
import 'package:chronoflow/providers/auth_provider.dart';
import 'package:chronoflow/widgets/background_image.dart';
import 'package:chronoflow/widgets/registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          _buildRegistrationCenter(),
          if (_isLoading)
            ColoredBox(
              color: Colors.black.withAlpha(150),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitRegistrationForm(OrganiserRegistration orgReg) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).signUp(orgReg);
      
      if (!mounted) return;
      
      _showSnackBar('Registration succeeded', isError: false);
      await Navigator.pushReplacementNamed(context, Constants.authScreen);
    } on Exception catch (exception) {
      if (!mounted) return;
      
      _showSnackBar(
        exception.toString().contains('Exception:')
            ? exception.toString().replaceFirst('Exception: ', '')
            : 'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildRegistrationCenter() {
    return Container(
      padding: const EdgeInsets.all(60),
      color: Colors.white.withAlpha(150),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Constants.registrationFormTitle,
                style: const TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 5, 43, 74),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              RegistrationForm(
                submitRegistrationForm: _submitRegistrationForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
