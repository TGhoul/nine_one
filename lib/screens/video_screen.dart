import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nineone/models/video_model.dart';
import 'package:nineone/parser/nine_one_porn_parser.dart';
import 'package:nineone/widgets/video_overlay.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String viewKey;

  VideoScreen(this.viewKey);

  @override
  State createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  Future<VideoModel> _getPlayUrl() async {
    var headers = {
      HttpHeaders.userAgentHeader:
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
      HttpHeaders.acceptLanguageHeader:
          "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5",
      HttpHeaders.cacheControlHeader: "max-age=0",
      "Proxy-Connection": "keep-alive"
    };

    VideoModel model;
    try {
      var url = "http://91porn.com/view_video.php?${widget.viewKey}";
      print("url:   $url");
      Response response =
          await Dio().get(url, options: Options(headers: headers));
      model = new NineOnePornParser().parseVideo(response.toString());
      return model;
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
    return model;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPlayUrl(),
        builder: (BuildContext context, AsyncSnapshot<VideoModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // 请求失败，显示错误
              return Text("Error: ${snapshot.error}");
            } else {
              _controller =
                  VideoPlayerController.network(snapshot.data.videoUrl);
              _initializeVideoPlayerFuture = _controller.initialize();
              // 请求成功，显示数据
              return Scaffold(
                  body: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_controller),
                          PlayPauseOverlay(controller: _controller),
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true),
                        ],
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ));
            }
          } else {
            // 请求未结束，显示loading
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
