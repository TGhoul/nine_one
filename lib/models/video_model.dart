class VideoModel {
  int id;
  String videoUrl;

  String videoId;

  // 同authorId，形式不一样，变换过的用于查看用户其他视频
  String ownerId;

  // ownerId，形式不一样，原始id，用于收藏视频
  String authorId;
  String thumbImgUrl;
  String videoName;
  String ownerName;
  String addDate;
  String userOtherInfo;

  @override
  String toString() {
    return 'Video{id: $id, videoUrl: $videoUrl, videoId: $videoId, ownerId: $ownerId, authorId: $authorId, thumbImgUrl: $thumbImgUrl, videoName: $videoName, ownerName: $ownerName, addDate: $addDate, userOtherInfo: $userOtherInfo}';
  }
}
