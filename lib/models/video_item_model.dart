import 'package:nineone/models/video_model.dart';

class VideoItemModel {
  int id;
  String viewKey;
  String title;
  String imgUrl;
  String duration;
  String info;
  int videoResultId;

  VideoModel video;
  int downloadId;

  int progress;
  int speed;
  int soFarBytes;
  int totalFarBytes;
  int status;
  DateTime addDownloadDate;
  DateTime finishedDownloadDate;
  DateTime viewHistoryDate;

  @override
  String toString() {
    return 'VideoItem{id: $id, viewKey: $viewKey, title: $title, imgUrl: $imgUrl, duration: $duration, info: $info, videoResultId: $videoResultId, video: $video, downloadId: $downloadId, progress: $progress, speed: $speed, soFarBytes: $soFarBytes, totalFarBytes: $totalFarBytes, status: $status, addDownloadDate: $addDownloadDate, finishedDownloadDate: $finishedDownloadDate, viewHistoryDate: $viewHistoryDate}';
  }
}
