import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/core.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewImage extends StatefulWidget {
  final PostModel post;

  ViewImage({this.post});

  @override
  _ViewImageState createState() => _ViewImageState();
}

final DateTime timestamp = DateTime.now();

currentUserId() {
  return getDbId();
}

UserModel user;

class _ViewImageState extends State<ViewImage> {
  StreamController<bool> _isLikedController = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    initComments();
  }

  initComments() async {
    List<Map<String, dynamic>> comments =
        await getComments(widget.post.commentAddr, null, -1);
    _isLikedController.add(comments
            .where((element) =>
                element['isLike'] == true &&
                element['userId'] == currentUserId())
            .length >
        0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildImage(context),
      ),
      bottomNavigationBar: BottomAppBar(
          elevation: 0.0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                Column(
                  children: [
                    Text(
                      widget.post.username,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 3.0),
                    Row(
                      children: [
                        Icon(Feather.clock, size: 13.0),
                        SizedBox(width: 3.0),
                        Text(timeago.format(widget.post.timestamp.toDate())),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                buildLikeButton(),
              ]),
            ),
          )),
    );
  }

  buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: CachedNetworkImage(
          imageUrl: widget.post.mediaUrl,
          placeholder: (context, url) {
            return circularProgress(context);
          },
          errorWidget: (context, url, error) {
            return Icon(Icons.error);
          },
          height: 400.0,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
        ),
      ),
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
            icon: snapshot.data
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
}
