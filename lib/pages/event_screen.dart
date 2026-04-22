import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/providers/auth_provider.dart';
import 'package:chronoflow/widgets/background_image.dart';
import 'package:chronoflow/widgets/landing_page_view.dart';
import 'package:chronoflow/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventScreen extends ConsumerStatefulWidget {
  final bool showBackground;

  const EventScreen({super.key, this.showBackground = false});
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

  Future<String?> fetchOtt() {
    return ref.read(authProvider.notifier).exchangeJwtForOtt();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return LandscapeScaffold(
            handleSignOut: handleSignOut,
            fetchOtt: fetchOtt,
            showBackground: widget.showBackground,
          );
        } else {
          return PortraitScaffold(
            handleSignOut: handleSignOut,
            fetchOtt: fetchOtt,
            showBackground: widget.showBackground,
          );
        }
      },
    );
  }
}

class LandscapeScaffold extends StatelessWidget {
  final Future<void> Function(BuildContext) handleSignOut;
  final Future<String?> Function() fetchOtt;
  final bool showBackground;
  const LandscapeScaffold({
    required this.handleSignOut,
    required this.fetchOtt,
    required this.showBackground,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (showBackground) const BackgroundImage(),
          Row(
            children: [
              MainDrawer(
                color: Colors.white.withValues(alpha: 0.9),
                signOut: () => handleSignOut(context),
              ),
              Expanded(
                child: LandingPageView(
                  fetchOtt: fetchOtt,
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
  final Future<String?> Function() fetchOtt;
  final bool showBackground;
  const PortraitScaffold({
    required this.handleSignOut,
    required this.fetchOtt,
    required this.showBackground,
    super.key,
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
          if (showBackground) const BackgroundImage(),
          LandingPageView(
            fetchOtt: fetchOtt,
          ),
        ],
      ),
    );
  }
}
