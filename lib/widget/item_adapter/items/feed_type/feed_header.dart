//  | 头像 | 用户名             | 按钮 |
//  |     | 来自xx 机型               |
part of './feed.item.dart';

class FeedItemHeader extends StatelessWidget {
  final String headImgUrl;
  final String userName;
  final String subTitle1;
  final String phoneName; // 可能有
  final dynamic source;
  final Function(dynamic) delete;

  const FeedItemHeader(
      {Key key,
      this.source,
      this.headImgUrl,
      this.userName,
      this.subTitle1,
      this.phoneName,
      this.delete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = DateTime.fromMillisecondsSinceEpoch(
            int.tryParse((source["lastupdate"]).toString()) * 1000)
        .toUtc();

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserSpacePage(
                uid: source["uid"],
              ),
            ));
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExtendedImage.network(
              headImgUrl,
              cache: true,
              width: 41,
              height: 41,
              shape: BoxShape.circle,
            ),
            VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const VerticalDivider(
                        color: Colors.transparent,
                        width: 8,
                      ),
                      LevelLabel(source["userInfo"]["level"]),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: HtmlText(
                          html:
                              " ${t.year == DateTime.now().year ? "" : "${t.year}年"}${t.month}月${t.day}日${t.hour}:${t.minute} " +
                                  subTitle1 +
                                  " $phoneName ",
                          shrinkToFit: true,
                          defaultTextStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .color
                                .withAlpha(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<int>(
              icon: Icon(Icons.keyboard_arrow_down),
              onSelected: (value) async {
                // TODO:
                switch (value) {
                  case 1:
                    if (UserStore.getUserUid(context) == null) {
                      showToLoginSnackBar(context);
                    } else {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => AddCollectSheet(
                                targetId: source["entityId"],
                              ));
                    }
                    break;
                  case 2:
                    Toast.show("此功能暂未完成", textStyle: context);
                    break;
                  case 3:
                    Toast.show("此功能也暂未完成", textStyle: context);
                    break;
                  case 4:
                    // handleOnLinkTap(source["shareUrl"], context);
                    showQRCode(context, source["shareUrl"]);
                    break;
                  case 5:
                    showSource(context);
                    break;
                  case 6:
                    final resp =
                        await FeedApi.deleteFeed(feedId: source["entityId"]);
                    Toast.show(resp["data"] ?? resp["message"],
                        textStyle: context, duration: 2);
                    delete?.call(source);
                    break;
                  case 7:
                    if ((await showDialog(
                            context: context,
                            builder: (context) => BlockDialog(
                                  source: this.source,
                                ))) ??
                        false) {
                      delete.call(source);
                    }
                    ;
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 1,
                    child: Text("收藏"),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("复制"),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text("举报"),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: Text("手机酷安扫码打开"),
                  ),
                  PopupMenuItem(
                    value: 5,
                    child: Text("查看源数据"),
                  ),
                ]..addAll(source["uid"].toString() ==
                        UserStore.getUserUid(context).toString()
                    ? [
                        PopupMenuItem(
                          value: 6,
                          child: Text("删除动态"),
                        )
                      ]
                    : [
                        PopupMenuItem(
                          value: 7,
                          child: Text("屏蔽..."),
                        ),
                      ]);
              },
            ),
          ],
        ),
      ),
    );
  }

  showSource(final context) {
    final json = JsonEncoder.withIndent("  ").convert(source);
    Navigator.of(context).push(ScaleInRoute(
        widget: Scaffold(
      appBar: AppBar(
        title: Text("源"),
      ),
      body: TextField(
        scrollPadding: const EdgeInsets.all(8),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8),
        ),
        controller: TextEditingController.fromValue(
          TextEditingValue(text: json),
        ),
        maxLines: 100,
      ),
    )));
  }
}
