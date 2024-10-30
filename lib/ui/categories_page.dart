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
    show getSubCategoryTypeList, enableFiltersState;

class CategoryBook {
  final String title;
  final String thumbnail;
  final String tag;
  final String info;
  CategoryBook(
      {required this.title,
      required this.thumbnail,
      required this.tag,
      required this.info});
}

List<CategoryBook> categoriesTypeValues = [
  CategoryBook(
      info:
          "Timeless literary works often revered for their artistic merit and cultural significance.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/1%20classic.jpeg",
      title: "Classics",
      tag: "list/tag/classics"),
  CategoryBook(
      info:
          "Stories focused on romantic relationships, exploring love, passion, and emotional connections.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/2%20romance.jpeg",
      title: "Romance",
      tag: "list/tag/romance"),
  CategoryBook(
      info:
          "Narrative literature created from the imagination, not based on real events.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/3%20fiction.jpeg",
      title: "Fiction",
      tag: "list/tag/fiction"),
  CategoryBook(
      info:
          "Books targeted at teenage readers, addressing themes relevant to adolescence.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/4%20young%20adult.jpeg",
      title: "Young Adult",
      tag: "list/tag/young-adult"),
  CategoryBook(
      info:
          "A genre featuring magical elements, mythical creatures, and fantastical worlds.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/5%20fantasy%20book.jpeg",
      title: "Fantasy",
      tag: "list/tag/fantasy"),
  CategoryBook(
      info:
          "Literature that explores futuristic concepts, advanced technology, and space exploration.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/6%20science%20fiction.jpeg",
      title: "Science Fiction",
      tag: "list/tag/science-fiction"),
  CategoryBook(
      info:
          "Works based on factual information, including essays, biographies, and documentaries.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/7%20non%20fiction.jpeg",
      title: "Nonfiction",
      tag: "list/tag/non-fiction"),
  CategoryBook(
      info:
          "Books aimed at young readers, often with illustrations and simple narratives.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/8%20children.jpeg",
      title: "Children",
      tag: "list/tag/children"),
  CategoryBook(
      info:
          "Literature that examines past events, cultures, and significant historical figures.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/9%20history.jpeg",
      title: "History",
      tag: "list/tag/history"),
  CategoryBook(
      info:
          "Stories centered around suspenseful plots, often involving crime or puzzles to solve.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/10%20mystery.jpeg",
      title: "Mystery",
      tag: "list/tag/mystery"),
  CategoryBook(
      info:
          "Refers to the artwork and design that visually represents a book, influencing reader interest.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/11%20covers.jpeg",
      title: "Covers",
      tag: "list/tag/covers"),
  CategoryBook(
      info:
          "A genre designed to evoke fear, dread, or terror in the reader through suspenseful storytelling.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/12%20horror.jpeg",
      title: "Horror",
      tag: "list/tag/horror"),
  CategoryBook(
      info:
          "Novels set in a specific historical period, blending factual events with fictional characters.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/13%20historical%20fiction.jpeg",
      title: "Historical Fiction",
      tag: "list/tag/historical-fiction"),
  CategoryBook(
      info:
          "Often refers to critically acclaimed or popular books, usually categorized by rankings or awards.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/15%20best%20.jpeg",
      title: "Best",
      tag: "list/tag/best"),
  CategoryBook(
      info:
          "Refers to the names of books, which often reflect their themes or subject matter.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/16%20titles.jpeg",
      title: "Titles",
      tag: "list/tag/titles"),
  CategoryBook(
      info:
          "Books intended for readers aged 8-12, featuring age-appropriate themes and characters.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/17%20middle%20grade.jpeg",
      title: "Middle Grade",
      tag: "list/tag/middle-grade"),
  CategoryBook(
      info:
          "Stories that incorporate supernatural elements, including ghosts, vampires, and otherworldly beings.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/18%20paranormal.jpeg",
      title: "Paranormal",
      tag: "list/tag/paranormal"),
  CategoryBook(
      info:
          "A theme exploring the complexities and nuances of love in various forms and relationships.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/19%20love.jpeg",
      title: "Love",
      tag: "list/tag/love"),
  CategoryBook(
      info:
          "Literature that represents diverse sexual orientations and gender identities within the LGBTQ+ spectrum.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/20%20queer.jpeg",
      title: "Queer",
      tag: "list/tag/queer"),
  CategoryBook(
      info:
          "Works based on factual information, including essays, biographies, and documentaries.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/21%20nonfictino.jpeg",
      title: "Nonfiction",
      tag: "list/tag/nonfiction"),
  CategoryBook(
      info:
          "Novels combining romantic plots set against a historical backdrop.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/22%20historical%20romance.jpeg",
      title: "Historical Romance",
      tag: "list/tag/historical-romance"),
  CategoryBook(
      info:
          "Works set in modern times, often addressing current social issues and relatable characters.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/24%20contemporary.jpeg",
      title: "Contemporary",
      tag: "list/tag/contemporary"),
  CategoryBook(
      info:
          "A suspenseful genre focused on excitement, tension, and unexpected twists.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/25%20thriller.jpeg",
      title: "Thriller",
      tag: "list/tag/thriller"),
  CategoryBook(
      info:
          "Literature that explores women's experiences, perspectives, and empowerment.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/26%20women.jpeg",
      title: "Women",
      tag: "list/tag/women"),
  CategoryBook(
      info:
          "Nonfiction works detailing the life story of an individual, highlighting their achievements and challenges.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/27%20biography.jpeg",
      title: "Biography",
      tag: "list/tag/biography"),
  CategoryBook(
      info:
          "Inclusive literature representing the experiences of the lesbian, gay, bisexual, transgender, and queer community.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/28%20lgbtq.jpeg",
      title: "LGBTQ",
      tag: "list/tag/lgbtq"),
  CategoryBook(
      info:
          "A collection of related books that follow a common storyline or set of characters.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/29%20series%20.jpeg",
      title: "Series",
      tag: "list/tag/series"),
  CategoryBook(
      info:
          "Refers to prompts or contests encouraging creative thinking about book titles.",
      thumbnail:
          "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/30%20title%20chhallenge.jpeg",
      title: "Title Challenge",
      tag: "list/tag/title-challenge"),
];

class GenresPage extends ConsumerWidget {
  const GenresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = categoriesTypeValues;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final category = categories[index];
                    return BookInfoCard(
                      title: category.title,
                      thumbnail: category.thumbnail,
                      info: category.info,
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return CategoryListingPage(
                                url: category.tag,
                                title: category.title,
                              );
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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
                      maxLines: 3,
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
  const CategoryListingPage(
      {super.key, required this.url, required this.title});
  final double imageHeight = 145;
  final double imageWidth = 105;
  final String url;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksBasedOnGenre = ref.watch(getSubCategoryTypeList(url));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text("Openlib"),
          titleTextStyle: Theme.of(context).textTheme.displayLarge,
        ),
        body: booksBasedOnGenre.when(
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
                                ref.read(enableFiltersState.notifier).state =
                                    false;
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CachedNetworkImage(
                                        height: imageHeight,
                                        width: imageWidth,
                                        imageUrl: data[index].thumbnail!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: 0.1,
                                                  blurRadius: 1)
                                            ],
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5)),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                //   ref.refresh(getbooksBasedOnGenre);
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
            }));
  }
}
