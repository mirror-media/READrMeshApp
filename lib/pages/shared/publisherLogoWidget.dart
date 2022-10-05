import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/publisher.dart';

class PublisherLogoWidget extends StatelessWidget {
  final Publisher publisher;
  final double size;
  const PublisherLogoWidget(this.publisher, {this.size = 40, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color randomColor =
        Colors.primaries[int.parse(publisher.id) % Colors.primaries.length];
    Color textColor =
        randomColor.computeLuminance() > 0.5 ? meshBlack87 : Colors.white;
    List<String> splitTitle = publisher.title.split('');
    String firstLetter = '';
    for (int i = 0; i < splitTitle.length; i++) {
      if (splitTitle[i] != " ") {
        firstLetter = splitTitle[i];
        break;
      }
    }
    Widget child;
    Widget background = Container(
      alignment: Alignment.center,
      color: randomColor,
      padding: const EdgeInsets.all(5),
      child: AutoSizeText(
        firstLetter,
        style: TextStyle(color: textColor, fontSize: 30),
        minFontSize: 5,
      ),
    );
    if (publisher.logoUrl == null || publisher.logoUrl! == '') {
      child = background;
    } else if (publisher.logoUrl!.contains('svg')) {
      child = Container(
        color: Colors.white,
        child: SvgPicture.network(publisher.logoUrl!),
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: publisher.logoUrl!,
        placeholder: (context, url) => Container(
          color: Colors.grey,
        ),
        errorWidget: (context, url, error) => background,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: Theme.of(context).extension<CustomColors>()!.primaryLv6!,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}
