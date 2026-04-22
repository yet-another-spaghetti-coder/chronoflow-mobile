import 'dart:convert';

import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/providers/storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class LandingPageView extends ConsumerStatefulWidget {
  final Future<String?> Function() fetchOtt;
  const LandingPageView({
    required this.fetchOtt,
    super.key,
  });

  @override
  ConsumerState<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends ConsumerState<LandingPageView> {
  LandingData? landingData;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final ott = await widget.fetchOtt();
    if (ott == null || ott.isEmpty) {
      setState(() {
        errorMessage = 'Unable to get one-time token.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Constants.chronoflowBackend}${Constants.validateOttEndpoint}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(ott),
      );
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null && setCookie.isNotEmpty) {
        final refreshToken = _extractCookieValue(setCookie, 'refreshToken');
        final authorization = _extractCookieValue(setCookie, 'Authorization');
        final storage = ref.read(secureStorageServiceProvider);
        if (refreshToken != null) {
          await storage.saveRefreshCookie('refreshToken=$refreshToken');
        }
        if (authorization != null) {
          await storage.saveAuthorizationCookie('Authorization=$authorization');
        }
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final code = payload['code'];
      if (response.statusCode == 200 && code == 0) {
        setState(() {
          landingData = LandingData.fromJson(payload['data'] as Map<String, dynamic>);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = (payload['msg']?.toString().isNotEmpty ?? false)
              ? payload['msg'].toString()
              : 'validateOTT failed.';
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        errorMessage = 'Failed to load landing data.';
        isLoading = false;
      });
    }
  }

  String? _extractCookieValue(String rawSetCookie, String cookieName) {
    final match = RegExp('${RegExp.escape(cookieName)}=([^;]+)').firstMatch(rawSetCookie);
    return match?.group(1)?.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (landingData == null) {
      return const Center(child: Text('No landing data available.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Welcome, ${landingData!.user.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Email', value: landingData!.user.email),
                const SizedBox(height: 10),
                _InfoRow(label: 'Primary role', value: landingData!.user.role),
                const SizedBox(height: 22),
                Text(
                  'Assigned Roles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: landingData!.roles
                      .map(
                        (role) => Chip(
                          label: Text('${role.name} (${role.key})'),
                          backgroundColor: Colors.blueGrey.shade50,
                          side: BorderSide(color: Colors.blueGrey.shade100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class LandingData {
  final LandingUser user;
  final List<LandingRole> roles;

  const LandingData({required this.user, required this.roles});

  factory LandingData.fromJson(Map<String, dynamic> json) {
    return LandingData(
      user: LandingUser.fromJson(json['user'] as Map<String, dynamic>),
      roles: ((json['roles'] as List?) ?? []).whereType<Map<String, dynamic>>().map(LandingRole.fromJson).toList(),
    );
  }
}

class LandingUser {
  final String name;
  final String email;
  final String role;

  const LandingUser({
    required this.name,
    required this.email,
    required this.role,
  });

  factory LandingUser.fromJson(Map<String, dynamic> json) {
    return LandingUser(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}

class LandingRole {
  final String name;
  final String key;

  const LandingRole({required this.name, required this.key});

  factory LandingRole.fromJson(Map<String, dynamic> json) {
    return LandingRole(
      name: (json['name'] ?? '').toString(),
      key: (json['key'] ?? '').toString(),
    );
  }
}
