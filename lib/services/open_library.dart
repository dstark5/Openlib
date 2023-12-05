import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

class TrendingBookData {
  final String? title;
  final String? thumbnail;
  TrendingBookData({this.title, this.thumbnail});
}

class OpenLibrary {
  String url = "https://openlibrary.org/trending/daily";

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

  Future<List<TrendingBookData>> trendingBooks() async {
    try {
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20)));
      final response2 = await dio.get(
          "https://openlibrary.org/trending/daily?page=2",
          options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20)));
      return _parser('${response.data.toString()}${response2.data.toString()}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      rethrow;
    }
  }
}

class GoodReads {
  String url = "https://www.goodreads.com/shelf/show/trending";

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
              thumbnail:
                  thumbnail.toString().replaceAll("._SY75_.", "._SY225_.")),
        );
      }
    }
    return trendingBooks;
  }

  Future<List<TrendingBookData>> trendingBooks() async {
    try {
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20)));
      return _parser(response.data.toString());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      rethrow;
    }
  }
}

class PenguinRandomHouse {
  String url =
      "https://www.penguinrandomhouse.com/ajaxc/categories/books/?from=0&to=50&contentId=&elClass=book&dataType=html&catFilter=best-sellers";

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

  Future<List<TrendingBookData>> trendingBooks() async {
    try {
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20)));
      return _parser(response.data.toString());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      rethrow;
    }
  }
}
