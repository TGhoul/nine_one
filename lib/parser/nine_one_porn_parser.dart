import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flustars/flustars.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import 'package:nineone/models/video_item_model.dart';
import 'package:nineone/models/video_model.dart';

/// 91porn html parser
class NineOnePornParser {
  /// parse index html
  List<VideoItemModel> parseIndex(String html) {
    var document = parse(html);
    var container =
        document.getElementById("wrapper").querySelector("div.container");
    return parserByDivContainer(container);
  }

  /// parse video detail
  VideoModel parseVideo(String html) {
    VideoModel video = new VideoModel();
    if (html.contains("你每天只可观看10个视频")) {
      //设置标志位,用于上传日志
      return video;
    }

    Document doc = parse(html);

    // 先直接取source
    String videoUrl;
    if (doc.querySelector("video").querySelector("source") != null) {
      videoUrl =
          doc.querySelector("video").querySelector("source").attributes["src"];
    }

    if (StringUtils.isNullOrEmpty(videoUrl)) {
      // 找不到的话 解密
      RegExp regExp =
          new RegExp(r'document.write\(strencode\("(.+)","(.+)",.+\)\);');
      String param1 = "", param2 = "";
      if (regExp.hasMatch(html)) {
        RegExpMatch m = regExp.firstMatch(html);
        Codec<String, String> stringToBase64 = utf8.fuse(base64);
        param1 = stringToBase64.decode(m.group(1));
        param2 = m.group(2);
        String sourceStr = "";
        for (int i = 0, k = 0; i < param1.length; i++) {
          k = i % param2.length;
          sourceStr += "" +
              String.fromCharCode(
                  (param1.codeUnitAt(i) ^ param2.codeUnitAt(k)));
        }
        //Logger.t(TAG).d("视频source1：" + sourceStr);
        sourceStr = stringToBase64.decode(sourceStr);
        //Logger.t(TAG).d("视频source2：" + sourceStr);
        Document source = parse(sourceStr);
        videoUrl = source.querySelector("source").attributes["src"];
      } else {
        //如果都获取不到就找分享链接
        //Logger.t(TAG).e("解析加密链接失败，尝试获取分享链接");
//        String shareLink = doc
//            .querySelector("#linkForm2 #fm-video_link")
//            .text;
//        Document shareDoc = Jsoup.connect(shareLink)
//            .timeout(3000)
//            .get();
//        videoUrl = shareDoc.select("source").first().attr("src");
      }
    }

    video.videoUrl = videoUrl;
    //Logger.t(TAG).d("视频链接：" + videoUrl);

    int endIndex = videoUrl.indexOf(".mp4");
    int startIndex = videoUrl.substring(0, endIndex).lastIndexOf("/");
    String videoId = videoUrl.substring(startIndex + 1, endIndex);
    video.videoId = videoId;
    // Logger.t(TAG).d("视频Id：" + videoId);

    //这里解析的作者id已经变了，非纯数字了
    //        Document doc = Jsoup.parse(html);
    String ownerUrl = doc.querySelector("a[href*=UID]").attributes["href"];
    String ownerId =
        ownerUrl.substring(ownerUrl.indexOf("=") + 1, ownerUrl.length);
    video.ownerId = ownerId;
    // Logger.t(TAG).d("作者Id：" + ownerId);

    var favorite =
        doc.getElementById("addToFavLink").querySelector("#favorite");
    String uid = favorite.querySelector("#UID").text;
    String vid = favorite.querySelector("#VID").text;
    String authorId = favorite.querySelector("#VUID").text;

    //登录才会有uid
    if (StringUtils.isNullOrEmpty(uid)) {
      uid = "0";
    }

    // Logger.t(TAG).d("userId:::" + userId);

    //原始纯数字作者id，用于收藏接口
    video.authorId = authorId;

    // 作者昵称
    String ownerName = doc.querySelector("a[href*=UID]").text;
    video.ownerName = ownerName;
    // Logger.t(TAG).d("作者：" + ownerName);

    // 缩略图
    String thumbImg = doc.getElementById("player_one").attributes["poster"];
    video.thumbImgUrl = thumbImg;
    //Logger.t(TAG).d("缩略图：" + thumbImg);

    List<Element> elementsByClass =
        doc.getElementsByClassName("videodetails-yakov");
    for (Element element in elementsByClass) {
      Element header = element.querySelector("h4.login_register_header");
      if (header == null) {
        continue;
      }
      String h4Header = header.text.trim();
      if ("视频信息" == h4Header) {
        String allInfo = element.text;

        int addTime = allInfo.indexOf("添加时间");
        int author = allInfo.indexOf("作者");
        String addDate = "";
        if (addTime != -1 && author != -1) {
          addDate = allInfo.substring(addTime, author);
        }
        video.addDate = addDate;
        // Logger.t(TAG).d("添加时间：" + addDate);

        int regIndex = allInfo.indexOf("注册");
        int introduction = allInfo.indexOf("简介");
        String otherInfo = "";
        if (regIndex != -1 && introduction != -1) {
          otherInfo = allInfo.substring(regIndex, introduction);
        }
        video.userOtherInfo = otherInfo;
        // Logger.t(TAG).d(otherInfo);
      } else if ("此视频留言" == h4Header) {
      } else {
        video.videoName = h4Header;
        // Logger.t(TAG).d("视频标题：" + h4Header);
      }
    }
    return video;
  }

  /// parse video items
  List<VideoItemModel> parserByDivContainer(Element element) {
    List<VideoItemModel> v9PornItemList = <VideoItemModel>[];
    List<Element> select =
        element.querySelectorAll("div.row>div.col-sm-12>div.row>div");

    for (Element item in select) {
      Element a = item.querySelector("a");
      if (a == null) {
        continue;
      }
      VideoItemModel v9PornItem = new VideoItemModel();

      String title = a.getElementsByClassName("video-title").first.text.trim();
      v9PornItem.title = title;

      Element imgEle = a.querySelector("img.img-responsive");
      if (imgEle != null) {
        v9PornItem.imgUrl = imgEle.attributes["src"];
      }

      Element durationEle = a.querySelector("span.duration");
      if (durationEle != null) {
        v9PornItem.duration = durationEle.text.trim();
      } else {
        v9PornItem.duration = "00:00";
      }

      String contentUrl = a.attributes["href"];
      v9PornItem.viewKey = contentUrl.substring(contentUrl.indexOf("?") + 1);

      String allInfo = item.text;

      // Added: / 添加時間: / 添加时间:

      int start = allInfo.indexOf("添加时间:");
      if (start == -1) {
        start = allInfo.indexOf("Added:");
        if (start == -1) {
          start = allInfo.indexOf("添加時間:");
        }
      }

      String info = allInfo.substring(start);
      try {
        if ("00:00" == v9PornItem.duration) {
          String duration = allInfo.substring(
              allInfo.indexOf("时长:") + 3, allInfo.indexOf("查看"));
          v9PornItem.duration = duration;
        }
      } catch (e) {
        LogUtil.e("parse duration error: " + e);
      }
      v9PornItem.info = info;
      v9PornItemList.add(v9PornItem);
    }

    return v9PornItemList;
  }
}
