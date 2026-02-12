import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/providers/auth_provider.dart';
import 'package:chronoflow/providers/storage_provider.dart';
import 'package:chronoflow/widgets/background_image.dart';
import 'package:chronoflow/widgets/sidebar.dart';
import 'package:chronoflow/widgets/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});
  @override
  EventScreenState createState() => EventScreenState();
}

class EventScreenState extends ConsumerState<EventScreen> {
  Future<void> handleSignOut(BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) {
      await Navigator.pushReplacementNamed(context, Constants.authScreen);
    }
    return Future.value();
  }

  Future<String?> fetchCookie() {
    return ref.read(secureStorageServiceProvider).getToken();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return LandscapeScaffold(
            handleSignOut: handleSignOut,
            fetchCookie: fetchCookie,
          );
        } else {
          return PortraitScaffold(
            handleSignOut: handleSignOut,
            fetchCookie: fetchCookie,
          );
        }
      },
    );
  }
}

class LandscapeScaffold extends StatelessWidget {
  final Future<void> Function(BuildContext) handleSignOut;
  final Future<String?> Function() fetchCookie;
  const LandscapeScaffold({
    required this.handleSignOut, required this.fetchCookie, super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          Row(
            children: [
              MainDrawer(
                color: Colors.white.withValues(alpha: 0.9),
                signOut: () => handleSignOut(context),
              ),
              Expanded(
                child: WebViewWithLoading(
                  url: Constants.chronoflowFrontend,
                  fetchCookie: fetchCookie,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PortraitScaffold extends StatelessWidget {
  final Future<void> Function(BuildContext) handleSignOut;
  final Future<String?> Function() fetchCookie;
  const PortraitScaffold({
    required this.handleSignOut, required this.fetchCookie, super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Constants.appTitle)),
      drawer: MainDrawer(
        color: Colors.white.withValues(alpha: 0.9),
        signOut: () {
          handleSignOut(context);
        },
      ),
      body: Stack(
        children: [
          const BackgroundImage(),
          WebViewWithLoading(
            url: Constants.chronoflowFrontend,
            fetchCookie: fetchCookie,
          ),
        ],
      ),
    );
  }
}
