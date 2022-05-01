@JS()
library core;

import "dart:convert";
import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';
@JS('initIpfs')
external dynamic _initIpfs();
@JS("uploadBinary")
external dynamic _uploadBinary(Uint8List binary);
@JS("login")
external dynamic _login(String dbId);
@JS('registerUser')
external dynamic _registerUser(String name);
@JS('getDbId')
external String getDbId();
@JS('getMyProfile')
external dynamic _getMyProfile();
@JS('updateMyPhoto')
external dynamic updateMyPhoto(String path);
@JS('getUser')
external dynamic _getUser(String userAddr);
@JS('getAllFollowing')
external dynamic _getAllFollowing();
@JS('isFollowing')
external dynamic _isFollowing(String dbId);
@JS('follow')
external dynamic _follow(String dbId);
@JS('unfollow')
external dynamic _unfollow(String dbId);
@JS('signOut')
external dynamic signOut();
@JS('queryAllFollowingPosts')
external dynamic _queryAllFollowingPosts(int limit);
@JS('deleteNotifications')
external dynamic _deleteNotifications(List<String> notificationIds);
@JS("countMyPosts")
external dynamic _countMyPosts();
@JS("getMyPosts")
external dynamic _getMyPosts(String offset,int limit);
@JS("postMine")
external dynamic _postMine(String postJson);
@JS("deleteMyPost")
external dynamic _deleteMyPost(String hash);
@JS("countComments")
external dynamic _countComments(String commentAddr);
@JS("getComments")
external dynamic _getComments(String commentAddr,String offset,int limit);
@JS("addComment")
external dynamic _addComment(String commentAddr,String jsonStr);
@JS("like")
external dynamic _like(String commentAddr);
@JS("unlike")
external dynamic _unlike(String commentAddr);
Future initIpfs() async {
  await promiseToFuture(_initIpfs());
}
Future<String> uploadBinary(Uint8List binary) async{
  return await promiseToFuture(_uploadBinary(binary));
}
Future<String> loginDb(String dbId) async{
  return await promiseToFuture(_login(dbId));
}
Future<String> registerUser(String name) async{
  return await promiseToFuture(_registerUser(name));
}
Future<Map<String,dynamic>> getMyProfile() async{
  var any = await promiseToFuture(_getMyProfile());
  return json.decode(any);
}
Future<Map<String,dynamic>> getUser(String userAddr) async{
  var any = await promiseToFuture(_getUser(userAddr));
  return json.decode(any);
}
Future<Map<String,dynamic>> getAllFollowing() async{
  return await promiseToFuture(_getAllFollowing());
}
Future<bool> hasFollowing(String dbId) async{
  return await promiseToFuture(_isFollowing(dbId));
}
Future follow(String dbId) async{
  return await promiseToFuture(_follow(dbId));
}
Future unfollow(String dbId) async{
  return await promiseToFuture(_unfollow(dbId));
}
Future<List<Map<String,dynamic>>> queryAllFollowingPosts(int limit) async{
  List<dynamic> list = json.decode(await promiseToFuture(_queryAllFollowingPosts(limit)));
  return list.map((e) => e as Map<String,dynamic>).toList();
}
Future deleteNotifications(List<String> notificationIds) async{
  await promiseToFuture(_deleteNotifications(notificationIds));
}

Future<int> countMyPosts() async{
  return await promiseToFuture(_countMyPosts());
}

Future<List<Map<String,dynamic>>> getMyPosts(String offset,int limit) async{
  List<dynamic> list = json.decode(await promiseToFuture(_getMyPosts(offset, limit)));
  return list.map((e) => e as Map<String,dynamic>).toList();
}
Future postMine(Map<String,dynamic> map) async{
  await promiseToFuture(_postMine(json.encode(map)));
}

Future deleteMyPost(String hash) async{
  await promiseToFuture(_deleteMyPost(hash));
}
Future<int> countComments(String commentAddr) async{
  return await promiseToFuture(_countComments(commentAddr));
}
Future<List<Map<String,dynamic>>> getComments(String commentAddr,String offset,int limit) async{
  List<dynamic> list = json.decode(await promiseToFuture(_getComments(commentAddr,offset,limit)));
  return list.map((e) => e as Map<String,dynamic>).toList();
}
Future addComment(String commentAddr,String comment) async{
  Map<String,dynamic> map = {
    "comment":comment
  };
  await promiseToFuture(_addComment(commentAddr,json.encode(map)));
}

Future like(String commentAddr) async{
  await promiseToFuture(_like(commentAddr));
}
Future unlike(String commentAddr) async{
  await promiseToFuture(_unlike(commentAddr));
}