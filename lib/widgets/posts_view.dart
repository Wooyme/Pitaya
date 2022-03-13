import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/pages/profile.dart';
import 'package:social_media_app/screens/comment.dart';
import 'package:social_media_app/screens/view_image.dart';
import 'package:social_media_app/utils/core.dart';
import 'package:social_media_app/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Posts extends StatefulWidget {
  final PostModel post;

  Posts({this.post});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final DateTime timestamp = DateTime.now();
  StreamController<int> _commentsCountController = StreamController<int>();
  StreamController<int> _likesCountController = StreamController<int>();
  StreamController<bool> _isLikedController = StreamController<bool>();
  StreamController<Map<String, dynamic>> _ownerController =
      StreamController<Map<String, dynamic>>();
  StreamController<List<Map<String, dynamic>>> _commentsController =
      StreamController<List<Map<String, dynamic>>>();

  currentUserId() {
    return getDbId();
  }

  @override
  void initState() {
    super.initState();
    initComments();
    initOwner();
  }

  initComments() async {
    List<Map<String, dynamic>> comments =
        await getComments(widget.post.commentAddr, null, -1);
    _commentsController.add(comments);
    _commentsCountController.add(comments.length);
    _likesCountController
        .add(comments.where((element) => element['isLike'] == true).length);
    _isLikedController.add(comments
            .where((element) =>
                element['isLike'] == true &&
                element['userId'] == currentUserId())
            .length >
        0);
  }

  initOwner() async {
    Map<String, dynamic> owner = await getUser(widget.post.ownerId);
    _ownerController.add(owner);
  }

  //UserModel user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => ViewImage(post: widget.post)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildPostHeader(),
            Container(
              height: 320.0,
              width: MediaQuery.of(context).size.width - 18.0,
              child: cachedNetworkImage(widget.post.mediaUrl),
            ),
            Flexible(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                title: Text(
                  widget.post.description == null
                      ? ""
                      : widget.post.description,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.0),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Text(
                        timeago.format(widget.post.timestamp.toDate()),
                      ),
                      SizedBox(width: 3.0),
                      StreamBuilder(
                        stream: _likesCountController.stream,
                        builder: (context, AsyncSnapshot<int> snapshot) {
                          if (snapshot.hasData) {
                            return buildLikesCount(context, snapshot.data);
                          } else {
                            return buildLikesCount(context, 0);
                          }
                        },
                      ),
                      SizedBox(width: 5.0),
                      StreamBuilder(
                        stream: _commentsCountController.stream,
                        builder: (context, AsyncSnapshot<int> snapshot) {
                          if (snapshot.hasData) {
                            return buildCommentsCount(context, snapshot.data);
                          } else {
                            return buildCommentsCount(context, 0);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                trailing: Wrap(
                  children: [
                    buildLikeButton(),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.chat_bubble,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => Comments(post: widget.post),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count likes',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }

  buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Text(
        '-   $count comments',
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildPostHeader() {
    bool isMe = currentUserId() == widget.post.ownerId;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
      leading: buildUserDp(),
      title: Text(
        widget.post.username,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.post.location == null ? 'Wooble' : widget.post.location,
      ),
      trailing: isMe
          ? IconButton(
              icon: Icon(Feather.more_horizontal),
              onPressed: () => handleDelete(context),
            )
          : IconButton(
              ///Feature coming soon
              icon: Icon(CupertinoIcons.bookmark, size: 25.0),
              onPressed: () {},
            ),
    );
  }

  buildUserDp() {
    return StreamBuilder(
      stream: _ownerController.stream,
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          UserModel user = UserModel.fromJson(snapshot.data);
          return GestureDetector(
            onTap: () => showProfile(context, profileId: user?.id),
            child: CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
          );
        }
        return SizedBox( height: 100, width: 100);
      },
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: _isLikedController.stream,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return IconButton(
            onPressed: () {
              if (!snapshot.data) {
                like(widget.post.commentAddr);
              } else {
                unlike(widget.post.commentAddr);
              }
            },
            icon: !snapshot.data
                ? Icon(
                    CupertinoIcons.heart,
                  )
                : Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                  ),
          );
        }
        return SizedBox(width: 100,height: 100);
      },
    );
  }

  handleDelete(BuildContext parentContext) {
    //shows a simple dialog box
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text('Delete Post'),
              ),
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

//you can only delete your own posts
  deletePost() async {
    deleteMyPost(widget.post.postId);
  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }
}
