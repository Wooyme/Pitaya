import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/auth/register/register.dart';
import 'package:social_media_app/components/stream_builder_wrapper.dart';
import 'package:social_media_app/components/stream_grid_wrapper.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/screens/edit_profile.dart';
import 'package:social_media_app/screens/settings.dart';
import 'package:social_media_app/utils/core.dart';
import 'package:social_media_app/widgets/post_tiles.dart';
import 'package:social_media_app/widgets/posts_view.dart';

class Profile extends StatefulWidget {
  final profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>  {
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isToggle = true;
  bool isFollowing = false;
  UserModel users;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();
  StreamController<Map<String,dynamic>> _profileEvent;
  StreamController<int> _postNumEvent;
  StreamController<int> _followerNumEvent;
  StreamController<int> _followingNumEvent;
  StreamController<List<Map<String,dynamic>>> _postsEvent;
  currentUserId() {
    return getDbId();
  }

  @override
  void initState() {
    super.initState();
    _profileEvent = new StreamController();
    _postNumEvent = new StreamController();
    _followerNumEvent = new StreamController();
    _followingNumEvent = new StreamController();
    _postsEvent = new StreamController();
    checkIfFollowing();
    initProfile();
  }

  checkIfFollowing() async {
    bool _isFollowing = await hasFollowing(currentUserId());
    setState(() {
      isFollowing = _isFollowing;
    });
  }

  initProfile() async{
    var myProfile = await getMyProfile();
    _profileEvent.add(myProfile);
    var myPostsNum = await countMyPosts();
    _postNumEvent.add(myPostsNum);
    var myPosts = await getMyPosts(null, -1); //todo maybe pagination?
    _postsEvent.add(myPosts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('WOOBLE'),
        actions: [
          widget.profileId == currentUserId()
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: GestureDetector(
                      onTap: () {
                        signOut();
                        Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => Register()));
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15.0),
                      ),
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            toolbarHeight: 5.0,
            collapsedHeight: 6.0,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              background: StreamBuilder(
                stream: _profileEvent.stream,
                builder: (context, AsyncSnapshot<Map<String,dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(snapshot.data);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user?.photoUrl),
                                radius: 40.0,
                              ),
                            ),
                            SizedBox(width: 20.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 32.0),
                                Row(
                                  children: [
                                    Visibility(
                                      visible: false,
                                      child: SizedBox(width: 10.0),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 130.0,
                                          child: Text(
                                            user?.username,
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w900),
                                            maxLines: null,
                                          ),
                                        ),
                                        Container(
                                          width: 130.0,
                                          child: Text(
                                            user?.country,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user?.email,
                                              style: TextStyle(
                                                // color: Color(0xff4D4D4D),
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    widget.profileId == currentUserId()
                                        ? InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                CupertinoPageRoute(
                                                  builder: (_) => Setting(),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                Icon(Feather.settings,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                                Text(
                                                  'settings',
                                                  style:
                                                      TextStyle(fontSize: 11.5),
                                                )
                                              ],
                                            ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                          child: user.bio.isEmpty
                              ? Container()
                              : Container(
                                  width: 200,
                                  child: Text(
                                    user?.bio,
                                    style: TextStyle(
                                      //    color: Color(0xff4D4D4D),
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          height: 50.0,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                StreamBuilder(
                                  stream: _postNumEvent.stream,
                                  builder: (context,
                                      AsyncSnapshot<int> snapshot) {
                                    if (snapshot.hasData) {
                                      return buildCount("POSTS", snapshot.data);
                                    } else {
                                      return buildCount("POSTS", 0);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.grey,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: _followerNumEvent.stream,
                                  builder: (context,
                                      AsyncSnapshot<int> snapshot) {
                                    if (snapshot.hasData) {
                                      return buildCount("FOLLOWERS", snapshot.data);
                                    } else {
                                      return buildCount("FOLLOWERS", 0);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.grey,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: _followingNumEvent.stream,
                                  builder: (context,
                                      AsyncSnapshot<int> snapshot) {
                                    if (snapshot.hasData) {
                                      return buildCount("FOLLOWING", snapshot.data);
                                    } else {
                                      return buildCount("FOLLOWING", 0);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        buildProfileButton(user),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index > 0) return null;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            'All Posts',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Spacer(),
                          buildIcons(),
                        ],
                      ),
                    ),
                    buildPostView()
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

//show the toggling icons "grid" or "list" view.
  buildIcons() {
    if (isToggle) {
      return IconButton(
          icon: Icon(Feather.list),
          onPressed: () {
            setState(() {
              isToggle = false;
            });
          });
    } else if (isToggle == false) {
      return IconButton(
        icon: Icon(Icons.grid_on),
        onPressed: () {
          setState(() {
            isToggle = true;
          });
        },
      );
    }
  }

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w900,
              fontFamily: 'Ubuntu-Regular'),
        ),
        SizedBox(height: 3.0),
        Text(
          label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
    );
  }

  buildProfileButton(user) {
    //if isMe then display "edit profile"
    bool isMe = widget.profileId == currentUserId();
    if (isMe) {
      return buildButton(
          text: "Edit Profile",
          function: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EditProfile(
                  user: user,
                ),
              ),
            );
          });
      //if you are already following the user then "unfollow"
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
      //if you are not following the user then "follow"
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollow,
      );
    }
  }

  buildButton({String text, Function function}) {
    return Center(
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Color(0xff597FDB),
              ],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  handleUnfollow() async {
    await unfollow(currentUserId());
  }

  handleFollow() async {
    await follow(currentUserId());
  }

  buildPostView() {
    // if (isToggle == true) {
    //   return buildGridPost();
    // } else if (isToggle == false) {
      return buildPosts();
    // }
  }

  buildPosts() {
    return StreamBuilderWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      stream: _postsEvent.stream,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, Map<String,dynamic> snapshot) {
        PostModel posts = PostModel.fromJson(snapshot);
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Posts(
            post: posts,
          ),
        );
      },
    );
  }

  // buildGridPost() {
  //   return StreamGridWrapper(
  //     shrinkWrap: true,
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //     stream: _postsEvent.stream,
  //     physics: NeverScrollableScrollPhysics(),
  //     itemBuilder: (_, Map<String,dynamic> snapshot) {
  //       PostModel posts = PostModel.fromJson(snapshot);
  //       return PostTile(
  //         post: posts,
  //       );
  //     },
  //   );
  // }

}
