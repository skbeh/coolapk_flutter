import 'package:coolapk_flutter/network/api/topic.api.dart';
import 'package:coolapk_flutter/widget/data_list/data_list.dart';
import 'package:coolapk_flutter/widget/data_list/template/template.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

/**
 * 二手交易为特殊页面
 */
class TopicDetailPage extends StatelessWidget {
  final String tag;
  const TopicDetailPage({Key key, @required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: () async {
      return TopicApi.topicDetail(tag);
    }(), builder: (context, snap) {
      final body = () {
        switch (snap.connectionState) {
          case ConnectionState.done:
            final data = snap.data['data'];
            return DefaultTabController(
              length: data['tabList'].length,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    actions: [
                      TopicFollowButton(
                          tag: data['title'],
                          initValue: data['userAction']['follow'] ?? 0),
                    ],
                    expandedHeight: 200,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.all(16.0)
                            .copyWith(top: kToolbarHeight, bottom: 56),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ExtendedImage.network(
                                    data['logo'],
                                    borderRadius: BorderRadius.circular(8),
                                    width: 50,
                                    height: 50,
                                    shape: BoxShape.rectangle,
                                    gaplessPlayback: true,
                                    cache: true,
                                  ),
                                  VerticalDivider(),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'],
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .headline6,
                                        ),
                                        Text(
                                          "${data['hot_num']}热度 ${data['commentnum']}讨论 ${data['follownum']}关注",
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.transparent),
                              Text(
                                data['intro'].replaceAll('\n', ''),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .subtitle2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    snap: false,
                    pinned: true,
                    floating: true,
                    bottom: TabBar(
                      tabs: data['tabList'].map<Widget>((tab) {
                        return Tab(
                          text: tab['title'],
                        );
                      }).toList(),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: data['tabList'].map<Widget>((tab) {
                    return ChangeNotifierProvider.value(
                      value:
                          DataListConfig(url: tab['url'], title: tab['title']),
                      child: SubTab(),
                    );
                  }).toList(),
                ),
              ),
            );
          default:
            return Center(child: CircularProgressIndicator());
        }
      }();
      return Scaffold(
        appBar: snap.connectionState == ConnectionState.done
            ? null
            : AppBar(
                title: Text(tag),
              ),
        body: body,
      );
    });
  }
}

class TopicFollowButton extends StatefulWidget {
  final String tag;
  final initValue;
  final Color color;
  TopicFollowButton(
      {Key key, @required this.tag, this.initValue, this.color = Colors.white})
      : super(key: key);

  @override
  _TopicFollowButtonState createState() => _TopicFollowButtonState();
}

class _TopicFollowButtonState extends State<TopicFollowButton> {
  bool value = false;
  @override
  void initState() {
    value = widget.initValue == 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            activeColor: Colors.pink,
            value: value,
            onChanged: (value) {
              var _lv = this.value;
              setState(() {
                this.value = value;
              });
              TopicApi.followTag(widget.tag, unFollow: !value).then((value) {
                if (!value) {
                  setState(() {
                    this.value = _lv;
                  });
                  Toast.show("操作失败，请重试", textStyle: context);
                }
              });
            },
          ),
          Text(
            value ? "已关注" : "关注",
            style: TextStyle(color: widget.color),
          ),
          const VerticalDivider(color: Colors.transparent),
        ],
      ),
    );
  }
}
