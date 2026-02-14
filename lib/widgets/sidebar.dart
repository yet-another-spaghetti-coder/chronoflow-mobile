import 'package:chronoflow/core/constants.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final Color color;
  final VoidCallback signOut;
  const MainDrawer({required this.color, required this.signOut, super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      elevation: 2,
      backgroundColor: color,
      child: Column(
        children: [
          buildDrawerHeader(),
          buildListTile(
            icon: Icons.home,
            text: 'HOME',
            onTap: () => Navigator.pushReplacementNamed(context, Constants.eventScreen),
          ),
          buildListTile(icon: Icons.logout, text: 'LOGOUT', onTap: signOut),
        ],
      ),
    );
  }

  Widget buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.white),
      child: Center(
        child: Column(
          children: [
            const FlutterLogo(size: 100),
            Text(Constants.sidebarTitle),
          ],
        ),
      ),
    );
  }

  Widget buildListTile({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      hoverColor: Colors.white,
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
