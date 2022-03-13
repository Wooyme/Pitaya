import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_media_app/components/notification_stream_wrapper.dart';
import 'package:social_media_app/models/notification.dart';
import 'package:social_media_app/utils/core.dart';
import 'package:social_media_app/widgets/notification_items.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  StreamController<List<Map<String, dynamic>>> _notificationEvent;

  currentUserId() {
    return getDbId();
  }

  @override
  void initState() {
    super.initState();
    _notificationEvent = new StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () => deleteAllItems(),
              child: Text(
                'CLEAR',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          getActivities(),
        ],
      ),
    );
  }

  getActivities() {
    return ActivityStreamWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      stream: _notificationEvent.stream,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, Map<String, dynamic> snapshot) {
        ActivityModel activities = ActivityModel.fromJson(snapshot);
        return ActivityItems(
          activity: activities,
        );
      },
    );
  }

  deleteAllItems() async {
    //delete all notifications associated with the authenticated user
    await deleteNotifications(null);
  }
}
