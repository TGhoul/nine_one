import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayPauseOverlay extends StatelessWidget {
  const PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      },
                      icon: Icon(Icons.play_arrow),
                      color: Colors.white,
                      iconSize: 50.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onDoubleTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

class VolumeBrightnessOverlay extends StatefulWidget {
  const VolumeBrightnessOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  _VolumeBrightnessOverlayState createState() =>
      _VolumeBrightnessOverlayState();
}

class _VolumeBrightnessOverlayState extends State<VolumeBrightnessOverlay> {
  int volume;
  int brightness;
  bool _dragging = false;

  VideoPlayerController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: !_dragging
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 100.0,
                        ),
                        Text('$volume'),
                      ],
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onVerticalDragStart: (detail) {
            setState(() {
              _dragging = true;
            });
          },
        ),
      ],
    );
  }
}
