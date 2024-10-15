// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

class TrendingBookData {
  final String? title;
  final String? thumbnail;
  TrendingBookData({this.title, this.thumbnail});
}

abstract class TrendingBooksImpl {
  String url = '';
  int timeOutDuration = 20;
  List<TrendingBookData> _parser(dynamic data);

  Future<List<TrendingBookData>> trendingBooks() async {
    try {
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(
              sendTimeout: Duration(seconds: timeOutDuration),
              receiveTimeout: Duration(seconds: timeOutDuration)));
      return _parser(response.data.toString());
    } on DioException catch (e) {
      return [];
    }
  }
}

class OpenLibrary extends TrendingBooksImpl {
  OpenLibrary() {
    super.url = "https://openlibrary.org/trending/daily";
  }

  @override
  List<TrendingBookData> _parser(data) {
    var document = parse(data.toString());
    var bookList = document.querySelectorAll('li[class="searchResultItem"]');
    List<TrendingBookData> trendingBooks = [];
    for (var element in bookList) {
      if (element.querySelector('h3[class="booktitle"]')?.text != null &&
          element.querySelector('img[itemprop="image" ]')?.attributes['src'] !=
              null) {
        String? thumbnail =
            element.querySelector('img[itemprop="image" ]')?.attributes['src'];
        trendingBooks.add(
          TrendingBookData(
              title:
                  element.querySelector('h3[class="booktitle"]')?.text.trim(),
              thumbnail: 'https:${thumbnail.toString()}'),
        );
      }
    }
    return trendingBooks;
  }

  @override
  Future<List<TrendingBookData>> trendingBooks() async {
    try {
      final dio = Dio();
      const timeOutDuration = 5;
      final response = await dio.get(url,
          options: Options(
              sendTimeout: const Duration(seconds: timeOutDuration),
              receiveTimeout: const Duration(seconds: timeOutDuration)));
      final response2 = await dio.get(
          "https://openlibrary.org/trending/daily?page=2",
          options: Options(
              sendTimeout: const Duration(seconds: timeOutDuration),
              receiveTimeout: const Duration(seconds: timeOutDuration)));
      return _parser('${response.data.toString()}${response2.data.toString()}');
    } on DioException catch (e) {
      return [];
    }
  }
}

class GoodReads extends TrendingBooksImpl {
  GoodReads() {
    super.url = "https://www.goodreads.com/shelf/show/trending";
  }

  @override
  List<TrendingBookData> _parser(data) {
    var document = parse(data.toString());
    var bookList = document.querySelectorAll('div[class="elementList"]');
    List<TrendingBookData> trendingBooks = [];
    for (var element in bookList) {
      if (element
                  .querySelector('a[class="leftAlignedImage"]')
                  ?.attributes['title'] !=
              null &&
          element.querySelector('img')?.attributes['src'] != null) {
        String? thumbnail = element.querySelector('img')?.attributes['src'];
        trendingBooks.add(
          TrendingBookData(
              title: element
                  .querySelector('a[class="leftAlignedImage"]')
                  ?.attributes['title']
                  .toString()
                  .trim(),
              thumbnail: thumbnail
                  .toString()
                  .replaceAll("._SY75_.", "._SY225_.")
                  .replaceAll("._SX50_.", "._SX148_.")),
        );
      }
    }
    return trendingBooks;
  }
}

class PenguinRandomHouse extends TrendingBooksImpl {
  PenguinRandomHouse() {
    super.url =
        "https://www.penguinrandomhouse.com/ajaxc/categories/books/?from=0&to=50&contentId=&elClass=book&dataType=html&catFilter=best-sellers";
  }

  @override
  List<TrendingBookData> _parser(data) {
    var document = parse(data.toString());
    var bookList = document.querySelectorAll('div[class="book"]');
    List<TrendingBookData> trendingBooks = [];
    for (var element in bookList) {
      if (element.querySelector('div[class="title"]')?.text != null &&
          element
                  .querySelector('img[class="responsive_img"]')
                  ?.attributes['src'] !=
              null) {
        String? thumbnail = element
            .querySelector('img[class="responsive_img"]')
            ?.attributes['src'];
        trendingBooks.add(
          TrendingBookData(
              title: element
                  .querySelector('div[class="title"]')
                  ?.text
                  .toString()
                  .trim(),
              thumbnail: thumbnail.toString()),
        );
      }
    }
    return trendingBooks;
  }
}

class BookDigits extends TrendingBooksImpl {
  BookDigits() {
    super.url = "https://bookdigits.com/fresh";
  }

  @override
  List<TrendingBookData> _parser(data) {
    var document = parse(data.toString());
    var bookList = document.querySelectorAll('div[class="list-row"]');
    List<TrendingBookData> trendingBooks = [];
    for (var element in bookList) {
      if (element.querySelector('div[class="list-title link-reg"]')?.text !=
              null &&
          element.querySelector('img')?.attributes['src'] != null) {
        String? thumbnail = element.querySelector('img')?.attributes['src'];
        trendingBooks.add(
          TrendingBookData(
              title: element
                  .querySelector('div[class="list-title link-reg"]')
                  ?.text
                  .toString()
                  .trim(),
              thumbnail: thumbnail.toString()),
        );
      }
    }
    return trendingBooks;
  }
}
