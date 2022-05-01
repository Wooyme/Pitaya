import 'dart:typed_data';

import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/screens/view_image.dart';
import 'package:social_media_app/services/services.dart';
import 'package:social_media_app/utils/core.dart';

class PostService extends Service {
//uploads profile picture to the users collection
  Future<String> uploadProfilePicture(Uint8List image) async {
    return await uploadBinary(image);
  }

//uploads post to the post collection
  uploadPost(Uint8List image, String location, String description) async {
    String link = image != null ? await uploadBinary(image) : null;
    user = UserModel.fromJson(await getMyProfile());
    String userId = getDbId();
    PostModel post = new PostModel();
    post.ownerId = userId;
    post.location = location;
    post.description = description;
    post.username = user.username;
    post.mediaUrl = link;
    await postMine(post.toJson());
  }
}
