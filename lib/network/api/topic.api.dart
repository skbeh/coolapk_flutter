import 'package:coolapk_flutter/network/dio_setup.dart';

class TopicApi {
  static Future topicDetail(String tag) async {
    final resp =
        await Network.apiDio.get("/topic/newTagDetail", queryParameters: {
      'tag': tag,
    });
    return resp.data;
  }

  static Future<bool> followTag(String tag, {bool unFollow = false}) async {
    try {
      final resp = await Network.apiDio.get(
          unFollow ? "/feed/unFollowTag" : "/feed/followTag",
          queryParameters: {
            'tag': tag,
          });
      print(resp.data);
      return resp.data['status'] == 1;
    } catch (err) {
      return false;
    }
  }
}
