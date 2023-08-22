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
      // physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                height: 240,
                width: 180,
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
                  height: 240,
                  width: 180,
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
              fontSize: 22,
              topPadding: 15,
              fontWeight: FontWeight.w600,
              // color: Colors.black,
              maxLines: 7,
            ),
            _TopPaddedText(
              text: data.publisher ?? "unknown",
              fontSize: 17,
              topPadding: 7,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              maxLines: 4,
            ),
            _TopPaddedText(
              text: data.author ?? "unknown",
              fontSize: 20,
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Text(
                          data.description ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
  final Color? color;
  final int maxLines;
  final FontWeight fontWeight;

  const _TopPaddedText(
      {required this.text,
      required this.fontSize,
      required this.topPadding,
      this.color,
      this.fontWeight = FontWeight.w400,
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
          fontWeight: fontWeight,
          color: color,
          // letterSpacing: 0.5,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
      ),
    );
  }
}
