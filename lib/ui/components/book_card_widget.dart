import 'package:flutter/material.dart';
import 'package:openlib/ui/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookInfoCard extends StatelessWidget {
  const BookInfoCard(
      {Key? key,
      required this.title,
      required this.author,
      required this.publisher,
      required this.thumbnail,
      required this.link,
      required this.onClick})
      : super(key: key);

  final String title;
  final String author;
  final String publisher;
  final String? thumbnail;
  final String link;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.black.withOpacity(0),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CachedNetworkImage(
              height: 180,
              width: 135,
              imageUrl: thumbnail ?? "",
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  // borderRadius: const BorderRadius.only(
                  //     topLeft: Radius.circular(15),
                  //     bottomLeft: Radius.circular(15),
                  //     bottomRight: Radius.circular(8),
                  //     topRight: Radius.circular(8)
                  //     ),
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: "#F8C0C8".toColor(),
                ),
                height: 120,
                width: 90,
              ),
              errorWidget: (context, url, error) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: "#F8C0C8".toColor(),
                  ),
                  height: 120,
                  width: 90,
                  child: const Center(
                    child: Icon(Icons.image_rounded),
                  ),
                );
              },
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(5),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        // color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                      publisher,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        // color: "#4D4D4D".toColor(),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: "#7B7B7B".toColor(),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
