import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:nineone/models/video_item_model.dart';
import 'package:nineone/parser/nine_one_porn_parser.dart';
import 'package:nineone/widgets/video_item.dart';

class VideoListScreen extends StatefulWidget {
  @override
  State createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> {
  final List<VideoItem> _videos = <VideoItem>[];
  final ScrollController _scrollController = ScrollController();

  _loadVideoItem() async {
    var headers = {
      HttpHeaders.userAgentHeader:
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
      HttpHeaders.acceptLanguageHeader:
          "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5",
      HttpHeaders.cacheControlHeader: "max-age=0",
      "Proxy-Connection": "keep-alive"
    };
    Response response = await Dio()
        .get("http://91porn.com/index.php", options: Options(headers: headers));
    var result = new NineOnePornParser().parseIndex(response.toString());
    var list = <VideoItem>[];
    for (VideoItemModel model in result) {
      list.add(new VideoItem(
          thumbImg: model.imgUrl,
          title: model.title,
          info: model.info,
          viewKey: model.viewKey));
    }
    setState(() {
      _videos.addAll(list);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVideoItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      appBar: AppBar(
        title: Text('NineOne'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.separated(
              controller: _scrollController,
              itemBuilder: (_, int index) => _videos[index],
              itemCount: _videos.length,
              separatorBuilder: (content, index) => Divider(),
            ),
          ),
        ],
      ),
    );
  }

  _buildBottomNavigationBar() => BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[300],
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              title: Text(''),
              icon: Icon(Icons.video_library),
            ),
            BottomNavigationBarItem(
              title: Text(''),
              icon: Icon(Icons.perm_identity),
            )
          ]);
}

getHttp() async {
  Response response = await Dio().get("http://91porn.com/index.php");
  var nineOnePornParser = new NineOnePornParser();
  var parseIndex = nineOnePornParser.parseIndex(response.toString());
  var viewKey2 = parseIndex.elementAt(0).viewKey;
  LogUtil.e("viewKey: " + viewKey2);
  var queryMap = viewKey2.split("&");
  Map<String, String> viewKeyQuery = LinkedHashMap<String, String>();
  for (String q in queryMap) {
    var keyValue = q.split("=");
    if (keyValue.length == 0) {
      continue;
    } else if (keyValue.length == 1) {
      viewKeyQuery[keyValue[0]] = "";
    } else {
      viewKeyQuery[keyValue[0]] = keyValue[1];
    }
  }
  var videoResponse = await Dio().get(
      "http://91porn.com/view_video.php?viewkey=beba2b9d8eb5bc0ac9d3&page=&viewtype=&category=");
  var parseVideo = nineOnePornParser.parseVideo(videoResponse.toString());
  LogUtil.e(parseVideo);
}
