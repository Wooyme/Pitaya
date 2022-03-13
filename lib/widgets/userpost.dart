import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/custom_card.dart';
import 'package:social_media_app/components/custom_image.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/pages/profile.dart';
import 'package:social_media_app/screens/comment.dart';
import 'package:social_media_app/screens/view_image.dart';
import 'package:social_media_app/services/post_service.dart';
import 'package:social_media_app/utils/core.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserPost extends StatelessWidget {
  final PostModel post;

  UserPost({this.post});
  final DateTime timestamp = DateTime.now();
  
  currentUserId() {
    return getDbId();
  }

  final PostService services = PostService();
  final StreamController<int> _followNumEvent = new StreamController();
  final StreamController<int> _commentsNumEvent = new StreamController();
  final StreamController<bool> _isFollowingEvent = new StreamController();
  final StreamController<Map<String,dynamic>> _userEvent = new StreamController();
  
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: null,
      borderRadius: BorderRadius.circular(10.0),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (BuildContext context, VoidCallback _) {
          return ViewImage(post: post);
        },
        closedElevation: 0.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        onClosed: (v) {},
        closedColor: Theme.of(context).cardColor,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return Stack(
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    child: CustomImage(
                      imageUrl: post?.mediaUrl ?? '',
                      height: 300.0,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Row(
                            children: [
                              buildFollowButton(),
                              InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => Comments(post: post),
                                    ),
                                  );
                                },
                                child: Icon(
                                  CupertinoIcons.chat_bubble,
                                  size: 25.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: StreamBuilder(
                                  stream: _followNumEvent.stream,
                                  builder: (context,
                                      AsyncSnapshot<int> snapshot) {
                                    if (snapshot.hasData) {
                                      return buildFollowersCount(context, snapshot.data);
                                    } else {
                                      return buildFollowersCount(context, 0);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 5.0),
                            StreamBuilder(
                              stream: _commentsNumEvent.stream,
                              builder: (context,
                                  AsyncSnapshot<int> snapshot) {
                                if (snapshot.hasData) {
                                  return buildCommentsCount(context, snapshot.data);
                                } else {
                                  return buildCommentsCount(context, 0);
                                }
                              },
                            ),
                          ],
                        ),
                        Visibility(
                          visible: post.description != null &&
                              post.description.toString().isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 3.0),
                            child: Text(
                              '${post?.description ?? ""}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                                fontSize: 15.0,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.0),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(timeago.format(post.timestamp.toDate()),
                              style: TextStyle(fontSize: 10.0)),
                        ),
                        // SizedBox(height: 5.0),
                      ],
                    ),
                  )
                ],
              ),
              buildUser(context),
            ],
          );
        },
      ),
    );
  }

  buildFollowButton() {
    return StreamBuilder(
      stream: _isFollowingEvent.stream,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return IconButton(
            onPressed: () {
              if (snapshot.data) {
                follow(post.ownerId);
              } else {
                unfollow(post.ownerId);
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
  
  buildFollowersCount(BuildContext context, int count) {
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

  buildUser(BuildContext context) {
    bool isMe = currentUserId() == post.ownerId;
    return StreamBuilder(
      stream: _userEvent.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel user = UserModel.fromJson(snapshot.data);
          return Visibility(
            visible: !isMe,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => showProfile(context, profileId: user?.id),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        user.photoUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 14.0,
                                backgroundColor: Color(0xff4D4D4D),
                                backgroundImage: CachedNetworkImageProvider(
                                    user?.photoUrl ?? ""),
                              )
                            : CircleAvatar(
                                radius: 14.0,
                                backgroundColor: Color(0xff4D4D4D),
                              ),
                        SizedBox(width: 5.0),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${post?.username ?? ""}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff4D4D4D),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${post?.location ?? 'Wooble'}',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Color(0xff4D4D4D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
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
