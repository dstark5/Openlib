import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  final List<String>? mirrors;
  final String? description;
  final String? format;

  BookInfoData(
      {required String title,
      required String? author,
      required String? thumbnail,
      required String? publisher,
      required String? info,
      required String link,
      required String md5,
      required this.mirrors,
      required this.format,
      required this.description})
      : super(
            title: title,
            author: author,
            thumbnail: thumbnail,
            publisher: publisher,
            info: info,
            link: link,
            md5: md5);
}

class AnnasArchieve {
  String baseUrl = "https://annas-archive.se";

  final Dio dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/7.0.4 Mobile/16B91 Safari/605.1.15'
  }));

  String getMd5(String url) {
    String md5 = url.toString().split('/').last;
    return md5;
  }

  List<BookData> _parser(resData, String fileType) {
    var document =
        parse(resData.toString().replaceAll(RegExp(r"<!--|-->"), ''));
    var books = document.querySelectorAll(
        'a[class="js-vim-focus custom-a flex items-center relative left-[-10px] w-[calc(100%+20px)] px-[10px] py-2 outline-offset-[-2px] outline-2 rounded-[3px] hover:bg-[#00000011] focus:outline "]');

    List<BookData> bookList = [];

    for (var element in books) {
      var data = {
        'title': element.querySelector('h3')?.text,
        'thumbnail': element.querySelector('img')?.attributes['src'],
        'link': element.attributes['href'],
        'author': element.querySelector('div[class="truncate italic"]')?.text ??
            'unknown',
        'publisher':
            element.querySelector('div[class="truncate text-sm"]')?.text ??
                "unknown",
        'info': element
                .querySelector('div[class="truncate text-xs text-gray-500"]')
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

  Future<String?> _getMirrorLink(String url) async {
    try {
      final response = await dio.get(url);
      var document = parse(response.toString());
      var pTag = document.querySelector('p[class="mb-4"]');
      String? link = pTag?.querySelector('a')?.attributes['href'];
      return link;
    } catch (e) {
      // print(e);
      return null;
    }
  }

  Future<BookInfoData?> _bookInfoParser(resData, url) async {
    var document = parse(resData.toString());
    var main = document.querySelector('main[class="main"]');
    var ul = main?.querySelectorAll('ul[class="mb-4"]');

    List<String> mirrors = [];

    if (ul != null) {
      var anchorTags = [];
      if (ul.length == 2) {
        anchorTags = ul[1].querySelectorAll('a');
      } else {
        anchorTags = ul[0].querySelectorAll('a');
      }

      for (var element in anchorTags) {
        if (element.attributes['href']!.startsWith('https://')) {
          if (element.attributes['href'] != null) {
            mirrors.add(element.attributes['href']!);
          }
        } else if (element.attributes['href'] != null &&
            element.attributes['href']!.startsWith('/slow_download')) {
          if (element.text.contains('Slow Partner Server #1') != true) {
            String? url =
                await _getMirrorLink('$baseUrl${element.attributes['href']!}');
            if (url != null && url.isNotEmpty) {
              mirrors.add(url);
            }
          }
        }
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
              ?.querySelector(
                  'div[class="mt-4 line-clamp-[5] js-md5-top-box-description"]')
              ?.text ??
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
        mirrors: mirrors,
        description: data['description'],
      );
    } else {
      return null;
    }
  }

  Future<List<BookData>> searchBooks(
      {required String searchQuery,
      String content = "",
      String sort = "",
      String fileType = ""}) async {
    try {
      final String encodedURL = content == ""
          ? '$baseUrl/search?index=&q=$searchQuery&ext=$fileType&sort=$sort'
          : '$baseUrl/search?index=&q=$searchQuery&content=$content&ext=$fileType&sort=$sort';

      final response = await dio.get(encodedURL);
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
      final response = await dio.get(url);
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
