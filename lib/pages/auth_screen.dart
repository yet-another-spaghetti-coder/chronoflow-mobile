import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/providers/auth_provider.dart';
import 'package:chronoflow/states/auth_state.dart';
import 'package:chronoflow/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkLoginStatus();
    });
  }

  void onSignInPressed() {
    ref.read(authProvider.notifier).signIn();
  }

  void onSignUpPressed() {
    Navigator.pushReplacementNamed(context, Constants.registrationScreen);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isLoggedIn) {
        Navigator.pushReplacementNamed(context, Constants.eventScreen);
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occured'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
    return Scaffold(
      body: Stack(children: [const BackgroundImage(), buildAuthCenter(context)]),
    );
  }

  Widget buildAuthCenter(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            Constants.appTitle,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 5, 43, 74),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onSignInPressed,
            label: const Text(Constants.googleSignInButtonText),
            icon: const Icon(FontAwesomeIcons.google),
            style: ButtonStyle(
              fixedSize: WidgetStateProperty.all(const Size(330, 50)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onSignUpPressed,
            label: const Text(Constants.googleSignUpButtonText),
            icon: const Icon(FontAwesomeIcons.google),
            style: ButtonStyle(
              fixedSize: WidgetStateProperty.all(const Size(330, 50)),
            ),
          ),
        ],
      ),
    );
  }
}
