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
      required this.info,
      required this.link,
      required this.onClick})
      : super(key: key);

  final String title;
  final String author;
  final String publisher;
  final String? thumbnail;
  final String? info;
  final String link;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.tertiaryContainer,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CachedNetworkImage(
              height: 120,
              width: 90,
              imageUrl: thumbnail ?? "",
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                      publisher,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.headlineMedium?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (info != null && info!.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: "#767b91".toColor(),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
                              child: Text(
                                info!.contains('pdf') ? "PDF" : "Epub",
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        if (info != null && info!.isNotEmpty)
                          const SizedBox(
                            width: 3,
                          ),
                        Expanded(
                          child: Text(
                            author,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
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
