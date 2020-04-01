import 'dart:convert';

import 'package:coolapk_flutter/network/api/main.api.dart';
import 'package:coolapk_flutter/util/html_text.dart';
import 'package:coolapk_flutter/util/image_url_size_parse.dart';
import 'package:coolapk_flutter/widget/common_error_widget.dart';
import 'package:coolapk_flutter/widget/future_switch.dart';
import 'package:coolapk_flutter/widget/to_login_snackbar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class FeedDetailPage extends StatefulWidget {
  final String url;
  FeedDetailPage({Key key, this.url}) : super(key: key);

  @override
  _FeedDetailPageState createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  Map<String, dynamic> data;
  String get url => widget.url;
  String get feedId =>
      url.startsWith("/feed/") ? url.replaceAll("/feed/", "") : null;

  Future<bool> fetchData() async {
    if (data != null) return true;
    if (feedId == null) throw Exception("FeedID获取失败");
    final resp = await MainApi.getFeedDetail(feedId);
    data = resp;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final child =
              width > 860 ? _buildDesktop(context) : _buildMobile(context);
          return child;
        }
        if (snapshot.hasError) {
          return CommonErrorWidget(
            error: snapshot.error,
            onRetry: () {
              setState(() {});
            },
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("动态"),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildDesktop(final BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1189),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: ListView(
                children: _buildFeedDetail(context),
              )),
              Expanded(
                child: Text("reply"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(final BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(context, sliver: true),
        ],
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(_buildFeedDetail(context)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeedDetail(final BuildContext context) {
    final pjson = jsonDecode(data["message_raw_output"]);
    return <Widget>[
      pjson == null
          ? HtmlText(
              html: data["message"],
              shrinkToFit: true,
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: parseContent(context, pjson),
              )),
    ];
  }

  Widget _buildAppBar(final BuildContext context, {final bool sliver = false}) {
    final t = DateTime.fromMillisecondsSinceEpoch(
            int.tryParse((data["lastupdate"]).toString()) * 1000)
        .toUtc();
    final collected = (data["userAction"]["collect"] ?? 0) == 0 ? false : true;
    final tile = ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: ExtendedImage.network(
        data["userInfo"]["userSmallAvatar"],
        width: kToolbarHeight - 14,
        height: kToolbarHeight - 14,
        shape: BoxShape.circle,
      ),
      title: Text(
        data["username"],
        style: TextStyle(
          color: Theme.of(context).primaryTextTheme.bodyText1.color,
        ),
      ),
      subtitle: HtmlText(
        html:
            "${data["userInfo"]["verify_label"] ?? ""} ${t.year == DateTime.now().year ? "" : "${t.year}年"}${t.month}月${t.day}日${t.hour}:${t.minute} " +
                data["infoHtml"].toString() +
                " ${data["device_title"]} ",
        shrinkToFit: true,
        defaultTextStyle: TextStyle(
          color:
              Theme.of(context).primaryTextTheme.subtitle1.color.withAlpha(200),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton.icon(
            label: Text(collected ? "取消收藏" : "收藏动态"),
            textColor: Theme.of(context).primaryTextTheme.bodyText1.color,
            icon: Icon(collected ? Icons.star : Icons.star_border),
            onPressed: () {},
          ),
          Builder(builder: (context) {
            return FutureSwitch(
              initValue:
                  (data["userAction"]["followAuthor"] ?? 0) == 0 ? false : true,
              color: Theme.of(context).primaryColorDark,
              fontColor: Theme.of(context).primaryTextTheme.bodyText1.color,
              margin: const EdgeInsets.only(right: 8),
              future: (value) async {
                final resp = await MainApi.setFollowUser(data["uid"], value);
                if (resp["status"] == 401) {
                  showToLoginSnackBar(context, message: resp["message"]);
                  return false;
                } else {
                  if (resp["data"] == 1 && value == false) {
                    return false;
                  }
                }
                return true;
              },
              builder: (context, value, error) {
                if (value) {
                  return Text("取消关注");
                } else {
                  return Text("关注大佬");
                }
              },
            );
          }),
        ],
      ),
    );
    final double titleSpacing = data != null ? 0 : null;
    final title = data == null ? Text("获取中...") : tile;
    return sliver
        ? SliverAppBar(titleSpacing: titleSpacing, title: title)
        : AppBar(titleSpacing: titleSpacing, title: title);
  }

  Widget _buildFeedReply() {}
}

List<Widget> parseContent(final BuildContext context, dynamic json) {
  return json.map<Widget>((node) {
    switch (node["type"]) {
      case "text":
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: HtmlText(
            html: node["message"].toString(),
            shrinkToFit: true,
            defaultTextStyle: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.w600),
          ),
        );
      case "image":
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Material(
              child: InkWell(
                onTap: () {
                  // TODO:
                },
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 1.3),
                  child: ExtendedImage.network(
                    node["url"],
                    cache: true,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.transparent,
              height: 6,
            ),
            Center(
              child: Text(
                node["description"] ?? "",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        );
      default:
        return Text(
          "不支持的Node: " + node.toString(),
          style: TextStyle(color: Colors.red),
        );
    }
  }).toList();
}
