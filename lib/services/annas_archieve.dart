// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

class BookData {
  final String title;
  final String? author;
  final String? thumbnail;
  final String link;
  final String md5;
  final String? publisher;
  final String? info;

  BookData(
      {required this.title,
      this.author,
      this.thumbnail,
      required this.link,
      required this.md5,
      this.publisher,
      this.info});
}

class BookInfoData extends BookData {
  String? mirror;
  final String? description;
  final String? format;

  BookInfoData(
      {required super.title,
      required super.author,
      required super.thumbnail,
      required super.publisher,
      required super.info,
      required super.link,
      required super.md5,
      required this.format,
      required this.mirror,
      required this.description});
}

class AnnasArchieve {
  static const String baseUrl = "https://annas-archive.org";

  final Dio dio = Dio();

  Map<String, dynamic> defaultDioHeaders = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36",
  };

  String getMd5(String url) {
    String md5 = url.toString().split('/').last;
    return md5;
  }

  List<BookData> _parser(resData, String fileType) {
    var document =
        parse(resData.toString().replaceAll(RegExp(r"<!--|-->"), ''));
    var books = document.querySelectorAll('a');

    List<BookData> bookList = [];

    for (var element in books) {
      var data = {
        'title': element.querySelector('h3')?.text,
        'thumbnail': element.querySelector('img')?.attributes['src'],
        'link': element.attributes['href'],
        'author': element
                .querySelector(
                    'div[class="max-lg:line-clamp-[2] lg:truncate leading-[1.2] lg:leading-[1.35] max-lg:text-sm italic"]')
                ?.text ??
            'unknown',
        'publisher': element
                .querySelector(
                    'div[class="truncate leading-[1.2] lg:leading-[1.35] max-lg:text-xs"]')
                ?.text ??
            "unknown",
        'info': element
                .querySelector(
                    'div[class="line-clamp-[2] leading-[1.2] text-[10px] lg:text-xs text-gray-500"]')
                ?.text ??
            ''
      };

      if ((data['title'] != null && data['title'] != '') &&
          (data['link'] != null && data['link'] != '') &&
          (data['info'] != null &&
              ((fileType == "") &&
                      (data['info']!.contains('pdf') ||
                          data['info']!.contains('epub') ||
                          data['info']!.contains('cbr') ||
                          data['info']!.contains('cbz')) ||
                  ((fileType != "") && data['info']!.contains(fileType))))) {
        String link = baseUrl + data['link']!;
        String publisher = ((data['publisher']?.contains('0') == true &&
                        data['publisher']!.length < 2) ||
                    data['publisher'] == "") ==
                true
            ? "unknown"
            : data['publisher'].toString();

        BookData book = BookData(
          title: data['title'].toString(),
          author: data['author'],
          thumbnail: data['thumbnail'],
          link: link,
          md5: getMd5(data['link'].toString()),
          publisher: publisher,
          info: data['info'],
        );
        bookList.add(book);
      }
    }
    return bookList;
  }

  String getFormat(String info) {
    if (info.contains('pdf') == true) {
      return 'pdf';
    } else {
      if (info.contains('cbr')) return "cbr";
      if (info.contains('cbz')) return "cbz";
      return "epub";
    }
  }

  // Future<String?> _getMirrorLink(
  //     String url, String userAgent, String cookie) async {
  //   try {
  //     final response = await dio.get(url,
  //         options: Options(extra: {
  //           'withCredentials': true
  //         }, headers: {
  //           "Host": "annas-archive.org",
  //           "Origin": baseUrl,
  //           "Upgrade-Insecure-Requests": "1",
  //           "Sec-Fetch-Dest": "secure",
  //           "Sec-Fetch-Mode": "navigate",
  //           "Sec-Fetch-Site": "same-site",
  //           "Cookie": cookie,
  //           "User-Agent": userAgent
  //         }));

  //     var document = parse(response.data.toString());

  //     var pTag = document.querySelectorAll('p[class="mb-4"]');
  //     String? link = pTag[1].querySelector('a')?.attributes['href'];
  //     return link;
  //   } catch (e) {
  //     // print('${url} ${e}');
  //     if (e.toString().contains("403")) {
  //       throw jsonEncode({"code": "403", "url": url});
  //     }
  //     return null;
  //   }
  // }

  Future<BookInfoData?> _bookInfoParser(resData, url) async {
    var document = parse(resData.toString());
    var main = document.querySelector('main[class="main"]');
    var ul = main?.querySelectorAll('ul[class="list-inside mb-4 ml-1"]');

    // List<String> mirrors = [];

    // if (ul != null) {
    //   var anchorTags = [];

    // for (var e in ul) {
    //   anchorTags.insertAll(0, e.querySelectorAll('a'));
    // }

    //   for (var element in anchorTags) {
    //     if (element.attributes['href'] != null &&
    //         element.attributes['href']!.startsWith('/slow_download') &&
    //         element.attributes['href']!.endsWith('/2')) {
    //       String? url =
    //           await _getMirrorLink('$baseUrl${element.attributes['href']!}');
    //       if (url != null && url.isNotEmpty) {
    //         mirrors.add(url);
    //       }
    //     } else if (element.attributes['href']!.startsWith('https://')) {
    //       if (element.attributes['href'] != null &&
    //           element.attributes['href'].contains('ipfs') == true) {
    //         mirrors.add(element.attributes['href']!);
    //       }
    //     }
    //   }
    // }
    String? mirror;
    var anchorTags = [];

    if (ul != null) {
      for (var e in ul) {
        anchorTags.insertAll(0, e.querySelectorAll('a'));
      }
    }

    for (var element in anchorTags) {
      if (element.attributes['href'] != null &&
          element.attributes['href']!.startsWith('/slow_download') &&
          element.attributes['href']!.endsWith('/2')) {
        mirror = '$baseUrl${element.attributes['href']}';
      }
    }

    // print(mirrors);

    var data = {
      'title': main?.querySelector('div[class="text-3xl font-bold"]')?.text,
      'author': main?.querySelector('div[class="italic"]')?.text ?? "unknown",
      'thumbnail': main?.querySelector('img')?.attributes['src'],
      'link': url,
      'publisher':
          main?.querySelector('div[class="text-md"]')?.text ?? "unknown",
      'info':
          main?.querySelector('div[class="text-sm text-gray-500"]')?.text ?? '',
      'description': main
              ?.querySelector('div[class="mb-1"]')
              ?.text
              .replaceFirst("description", '') ??
          " "
    };

    if ((data['title'] != null && data['title'] != '') &&
        (data['link'] != null && data['link'] != '')) {
      String title = data['title'].toString().characters.skipLast(1).toString();
      String author =
          data['author'].toString().characters.skipLast(1).toString();
      String publisher = ((data['publisher']?.contains('0') == true &&
                      data['publisher']!.length < 2) ||
                  data['publisher'] == "") ==
              true
          ? "unknown"
          : data['publisher'].toString();

      return BookInfoData(
        title: title,
        author: author,
        thumbnail: main?.querySelector('img')?.attributes['src'],
        publisher: publisher,
        info: data['info'],
        link: data['link'],
        md5: getMd5(data['link'].toString()),
        format: getFormat(data['info']),
        mirror: mirror,
        description: data['description'],
      );
    } else {
      return null;
    }
  }

  String urlEncoder(
      {required String searchQuery,
      required String content,
      required String sort,
      required String fileType,
      required bool enableFilters}) {
    searchQuery = searchQuery.replaceAll(" ", "+");
    if (enableFilters == false) return '$baseUrl/search?q=$searchQuery';
    if (content == "" && sort == "" && fileType == "") {
      return '$baseUrl/search?q=$searchQuery';
    }
    return '$baseUrl/search?index=&q=$searchQuery&content=$content&ext=$fileType&sort=$sort';
  }

  Future<List<BookData>> searchBooks(
      {required String searchQuery,
      String content = "",
      String sort = "",
      String fileType = "",
      bool enableFilters = true}) async {
    try {
      final String encodedURL = urlEncoder(
          searchQuery: searchQuery,
          content: content,
          sort: sort,
          fileType: fileType,
          enableFilters: enableFilters);

      final response = await dio.get(encodedURL,
          options: Options(headers: defaultDioHeaders));
      if (!enableFilters) {
        return _parser(response.data, "");
      }
      return _parser(response.data, fileType);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      rethrow;
    }
  }

  Future<BookInfoData> bookInfo({required String url}) async {
    try {
      final response =
          await dio.get(url, options: Options(headers: defaultDioHeaders));
      BookInfoData? data = await _bookInfoParser(response.data, url);
      if (data != null) {
        return data;
      } else {
        throw 'unable to get data';
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      rethrow;
    }
  }
}
