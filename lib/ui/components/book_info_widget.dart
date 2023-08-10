import 'package:flutter/material.dart';
import 'package:openlib/ui/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookInfoWidget extends StatelessWidget {
  final Widget child;
  final dynamic data;

  const BookInfoWidget({Key? key, required this.child, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              height: 30,
            ),
            Center(
              child: CachedNetworkImage(
                height: 230,
                width: 170,
                imageUrl: data.thumbnail,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                  height: 230,
                  width: 170,
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                    height: 230,
                    width: 170,
                    child: const Center(
                      child: Icon(Icons.image_rounded),
                    ),
                  );
                },
              ),
            ),
            _TopPaddedText(
              text: data.title,
              fontSize: 19,
              topPadding: 15,
              color: Colors.black,
              maxLines: 7,
            ),
            _TopPaddedText(
              text: data.publisher ?? "unknown",
              fontSize: 15,
              topPadding: 7,
              color: "#595E60".toColor(),
              maxLines: 4,
            ),
            _TopPaddedText(
              text: data.author ?? "unknown",
              fontSize: 13,
              topPadding: 7,
              color: "#7F7F7F".toColor(),
              maxLines: 3,
            ),
            _TopPaddedText(
              text: data.info ?? "",
              fontSize: 11,
              topPadding: 9,
              color: "#A9A8A2".toColor(),
              maxLines: 4,
            ),
            // child slot of page
            child,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7, bottom: 10),
                  child: Text(
                    data.description ?? "",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: "#6B6B6B".toColor(),
                      letterSpacing: 1.5,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TopPaddedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double topPadding;
  final Color color;
  final int maxLines;

  const _TopPaddedText(
      {required this.text,
      required this.fontSize,
      required this.topPadding,
      required this.color,
      required this.maxLines,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
      ),
    );
  }
}
