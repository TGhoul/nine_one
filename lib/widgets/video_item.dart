import 'package:flutter/material.dart';
import 'package:nineone/screens/video_screen.dart';

class VideoItem extends StatelessWidget {
  final String thumbImg;
  final String title;
  final String info;
  final String viewKey;

  const VideoItem({Key key, this.thumbImg, this.title, this.info, this.viewKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Row(
          children: <Widget>[
            Image.network(
              thumbImg,
              width: 150,
              height: 95,
              fit: BoxFit.fill,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(info
                      .trim()
                      .replaceAll("\n", "")
                      .split(" ")
                      .map((e) => e.trim())
                      .join("")),
                ],
              ),
            )
          ],
        ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => VideoScreen(viewKey))));
  }
}
