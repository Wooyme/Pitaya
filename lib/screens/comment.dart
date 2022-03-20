import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/stream_comments_wrapper.dart';
import 'package:social_media_app/models/comments.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/post_service.dart';
import 'package:social_media_app/utils/core.dart';
import 'package:social_media_app/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final PostModel post;

  Comments({this.post});

  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  UserModel user;

  PostService services = PostService();
  final DateTime timestamp = DateTime.now();
  TextEditingController commentsTEC = TextEditingController();
  StreamController<int> _commentsCountController = StreamController<int>();
  StreamController<int> _likesCountController = StreamController<int>();
  StreamController<bool> _isLikedController = StreamController<bool>();
  StreamController<Map<String, dynamic>> _ownerController = StreamController<Map<String, dynamic>>();
  StreamController<List<Map<String, dynamic>>> _commentsController = StreamController<List<Map<String, dynamic>>>();

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
        .where((element) => element['isLike'] == true && element['userId'] == currentUserId()).length > 0);
  }

  initOwner() async {
    Map<String, dynamic> owner = await getUser(widget.post.ownerId);
    _ownerController.add(owner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.xmark_circle_fill,
          ),
        ),
        centerTitle: true,
        title: Text('Comments'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Flexible(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: buildFullPost(),
                  ),
                  Divider(thickness: 1.5),
                  Flexible(
                    child: buildComments(),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                constraints: BoxConstraints(
                  maxHeight: 190.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: commentsTEC,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(context).textTheme.headline6.color,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            hintText: "Write your comment...",
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color:
                                  Theme.of(context).textTheme.headline6.color,
                            ),
                          ),
                          maxLines: null,
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            await addComment(
                              widget.post.commentAddr,
                              commentsTEC.text
                            );
                            commentsTEC.clear();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.send,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                      ),
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

  buildFullPost() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.post.mediaUrl!=null?Container(
          height: 250.0,
          width: MediaQuery.of(context).size.width - 20.0,
          child: cachedNetworkImage(widget.post.mediaUrl),
        ):Container(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.description,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(
                        timeago.format(widget.post.timestamp.toDate()),
                        style: TextStyle(),
                      ),
                      SizedBox(width: 3.0),
                      StreamBuilder(
                        stream: _likesCountController.stream,
                        builder:
                            (context, AsyncSnapshot<int> snapshot) {
                          if (snapshot.hasData) {
                            return buildLikesCount(context, snapshot.data);
                          } else {
                            return buildLikesCount(context, 0);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              buildLikeButton(),
            ],
          ),
        ),
      ],
    );
  }

  buildComments() {
    return CommentsStreamWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      stream: _commentsController.stream,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, Map<String,dynamic> snapshot) {
        CommentModel comments = CommentModel.fromJson(snapshot);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(comments.userDp),
              ),
              title: Text(
                comments.username,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                timeago.format(comments.timestamp.toDate()),
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                comments.comment,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
            Divider()
          ],
        );
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
        return Container();
      },
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
}
