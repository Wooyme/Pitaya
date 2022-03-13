import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String postId;
  String ownerId;
  String username;
  String location;
  String description;
  String mediaUrl;
  Timestamp timestamp;
  String commentAddr;

  PostModel({
    this.postId,
    this.ownerId,
    this.location,
    this.description,
    this.mediaUrl,
    this.username,
    this.timestamp,
  });
  PostModel.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    ownerId = json['ownerId'];
    location = json['location'];
    username= json['username'];
    description = json['description'];
    mediaUrl = "https://avatars.githubusercontent.com/u/1";//json['mediaUrl'];
    timestamp = Timestamp(0,0);
    commentAddr = json['commentAddr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['ownerId'] = this.ownerId;
    data['location'] = this.location;
    data['description'] = this.description;
    data['mediaUrl'] = this.mediaUrl;
    data['timestamp'] = this.timestamp.seconds;
    data['username'] = this.username;
    data['commentAddr'] = this.commentAddr;
    return data;
  }
}
