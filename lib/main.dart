import 'package:flutter/material.dart';
import 'screens/video_list_screen.dart';

void main() => runApp(NineOneApp());

class NineOneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nine one',
      home: VideoListScreen(),
    );
  }
}
