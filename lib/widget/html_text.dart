import 'package:coolapk_flutter/page/detail/feed_detail.page.dart';
import 'package:coolapk_flutter/util/emoji.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class HtmlText extends StatelessWidget {
  final String html;
  final TextStyle defaultTextStyle;
  final bool shrinkToFit;
  final bool renderNewlines;
  final TextStyle linkStyle;
  final Function(String url) onLinkTap;
  const HtmlText({
    Key key,
    this.html,
    this.defaultTextStyle,
    this.shrinkToFit = true,
    this.linkStyle,
    this.onLinkTap,
    this.renderNewlines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Html(
      // useRichText: false,
      data: parseEmoji(html),
      // showImages: true,
      onLinkTap: onLinkTap ??
          (link) {
            handleOnLinkTap(link, context);
          },
      shrinkWrap: shrinkToFit,
      style: {
        "a": Style.fromTextStyle(
          linkStyle ??
              TextStyle(
                  color: Theme.of(context).accentColor,
                  decoration: TextDecoration.none),
        ),
        "html": Style.fromTextStyle(
          defaultTextStyle ?? const TextStyle(fontSize: 15),
        ).copyWith(
          whiteSpace:
              (renderNewlines ?? true) ? WhiteSpace.PRE : WhiteSpace.NORMAL,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
        "body": Style(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      },
      customRender: {
        // "*": (context, child, map, attr) {
        //   print(attr);
        //   return child;
        // },
        "emoji": (context, child, map, attr) {
          final img = attr.attributes["path"];
          print(img);
          try {
            return ExtendedImage.asset(
              img,
              width: 22,
              height: 22,
              filterQuality: FilterQuality.medium,
            );
          } catch (err) {
            return const SizedBox();
          }
        }
      },
    );
  }
}
