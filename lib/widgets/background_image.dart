import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget{
  final String localPath;
  const BackgroundImage({
    super.key,
    this.localPath = 'assets/images/bg.png'
  });
  @override
  Widget build(BuildContext context) {
   return Positioned.fill(
    child: Opacity(
      opacity: 0.5,
      child: Image.asset(localPath, fit: BoxFit.cover,repeat: ImageRepeat.repeat,width: double.infinity, height: double.infinity),
    ),
   );
  }
}