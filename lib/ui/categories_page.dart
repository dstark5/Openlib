// Flutter imports:
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/extensions.dart';
import 'package:openlib/ui/results_page.dart';
import 'package:openlib/ui/components/error_widget.dart';
import 'package:openlib/state/state.dart'
    show
        getSubCategoryTypeList,
        enableFiltersState;

class CategoryBook {
  final String title;  
  final String thumbnail;
  final String tag;

  CategoryBook({required this.title, required this.thumbnail,required this.tag});
}

List<CategoryBook> categoriesTypeValues = [
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg",  title: "Classics", tag: "list/tag/classics"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Romance", tag: "list/tag/romance"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Fiction", tag: "list/tag/fiction"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Young Adult", tag: "list/tag/young-adult"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Fantasy", tag: "list/tag/fantasy"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Science Fiction", tag: "list/tag/science-fiction"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Nonfiction", tag: "list/tag/non-fiction"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Children", tag: "list/tag/children"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "History", tag: "list/tag/history"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Mystery", tag: "list/tag/mystery"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Covers", tag: "list/tag/covers"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Horror", tag: "list/tag/horror"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Historical Fiction", tag: "list/tag/historical-fiction"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Gay", tag: "list/tag/gay"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Best", tag: "list/tag/best"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Titles", tag: "list/tag/titles"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Middle Grade", tag: "list/tag/middle-grade"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Paranormal", tag: "list/tag/paranormal"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Love", tag: "list/tag/love"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Queer", tag: "list/tag/queer"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Nonfiction", tag: "list/tag/nonfiction"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Historical Romance", tag: "list/tag/historical-romance"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "LGBT", tag: "list/tag/lgbt"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Contemporary", tag: "list/tag/contemporary"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Thriller", tag: "list/tag/thriller"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Women", tag: "list/tag/women"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Biography", tag: "list/tag/biography"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "LGBTQ", tag: "list/tag/lgbtq"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Series", tag: "list/tag/series"),
  CategoryBook(thumbnail: "https://static.vecteezy.com/system/resources/previews/022/692/148/non_2x/beautiful-image-of-lord-krishna-on-black-background-generative-ai-photo.jpeg", title: "Title Challenge", tag: "list/tag/title-challenge"),
];

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = categoriesTypeValues;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverToBoxAdapter(
              child: TitleText("Categories"),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final category = categories[index];
                    return BookInfoCard(
                      title: category.title,
                      thumbnail: category.thumbnail, // Handle null case
                      info: category.tag, // define info 
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return CategoryListingPage(url: category.tag, title: category.title,); // Update based on your logic
                            },
                          ),
                        );
                      },
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookInfoCard extends StatelessWidget {
  const BookInfoCard(
      {super.key,
      required this.title,
      required this.thumbnail,
      required this.info,
      required this.onClick});

  final String title;
  final String thumbnail;
  final String info;
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
              imageUrl: thumbnail,
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
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    Text(
                      info,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.headlineMedium?.color,
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

class CategoryListingPage extends ConsumerWidget {
  const CategoryListingPage({super.key, required this.url, required this.title});
  final double imageHeight = 145;
  final double imageWidth = 105;
  final String url ;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingBooks = ref.watch(getSubCategoryTypeList( url));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text("Openlib"),
          titleTextStyle: Theme.of(context).textTheme.displayLarge,
      ),
    body : trendingBooks.when(
        skipLoadingOnRefresh: false,
        data: (data) {
          return Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: TitleText(title),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(5),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 13.0,
                      mainAxisExtent: 205,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            ref.read(enableFiltersState.notifier).state = false;
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ResultPage(
                                  searchQuery: data[index].title!);
                            }));
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                    height: imageHeight,
                                    width: imageWidth,
                                    imageUrl: data[index].thumbnail!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.grey,
                                              spreadRadius: 0.1,
                                              blurRadius: 1)
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: "#E3E8E9".toColor(),
                                      ),
                                      height: imageHeight,
                                      width: imageWidth,
                                    ),
                                    errorWidget: (context, url, error) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey,
                                        ),
                                        height: imageHeight,
                                        width: imageWidth,
                                        child: const Center(
                                          child: Icon(Icons.image_rounded),
                                        ),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: SizedBox(
                                      width: imageWidth,
                                      child: Text(
                                        data[index].title!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        );
                      },
                      childCount: data.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, _) {
          return CustomErrorWidget(
            error: error,
            stackTrace: _,
            // onRefresh: () {
            //   // ignore: unused_result
            //   ref.refresh(getTrendingBooks);
            // },
          );
        },
        loading: () {
          return Center(
              child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
              strokeCap: StrokeCap.round,
            ),
          ));
        })
    );
  }
}



