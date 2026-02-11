import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          remember: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      // Add adaptive app bar if you want a header
      appBar: const AdaptiveAppBar(title: 'Login'),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            AdaptiveSnackBar.show(
              context,
              message: state.message,
              type: AdaptiveSnackBarType.error,
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ChronoFlow',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Event Management Platform',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveTextFormField(
                          controller: _usernameController,
                          placeholder: 'Username', // iOS style
                          prefix: const Icon(Icons.person),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          enabled: state is! AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveTextFormField(
                          controller: _passwordController,
                          placeholder: 'Password',
                          prefix: const Icon(Icons.lock),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          suffix: AdaptiveButton.icon(
                            icon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          enabled: state is! AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveListTile(
                          leading: AdaptiveSwitch(
                            value: _rememberMe,
                            onChanged: state is AuthLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _rememberMe = value;
                                    });
                                  },
                          ),
                          title: const Text('Remember me'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                            child: LinearProgressIndicator(),
                          );
                        }

                        return AdaptiveButton(
                          onPressed: _handleLogin,
                          label: 'Login',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveButton(
                          onPressed: state is AuthLoading ? null : () => context.push('/forgot-password'),
                          label: 'Forgot Password?',
                        );
                      },
                    ),
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
