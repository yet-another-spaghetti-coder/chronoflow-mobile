import 'package:flutter/material.dart';
import 'package:chronoflow/core/constants.dart';

class MainDrawer extends StatelessWidget{
  final Color color;
  final VoidCallback signOut;
  const MainDrawer({
    super.key,
    required this.color,
    required this.signOut });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
      elevation: 2,
      backgroundColor: color,
      child: Column(
        children: [
          buildDrawerHeader(),
          buildListTile(icon: Icons.logout, text: 'LOGOUT', onTap: signOut)
        ],
      )
      );
      
  }
  Widget buildDrawerHeader(){
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: Center(
        child: Column(
          children: [
            const FlutterLogo(size:100),
            Text(Constants.sidebarTitle),
          ],
        ),
      ));
  }
  Widget buildListTile({required IconData icon, required String text, required VoidCallback onTap}){
    return ListTile(
      hoverColor: Colors.white,
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}