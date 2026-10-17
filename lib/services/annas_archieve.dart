// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'dart:convert';

// ====================================================================
// DATA MODELS
// ====================================================================

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

// ====================================================================
// ANNA'S ARCHIVE SERVICE (ALL FIXES APPLIED)
// ====================================================================

class ArchiveRequestException implements Exception {
  const ArchiveRequestException({
    required this.url,
    this.needsBrowser = false,
    this.cause,
  });

  final String url;
  final bool needsBrowser;
  final Object? cause;

  @override
  String toString() => needsBrowser
      ? 'Complete the website check at ${Uri.parse(url).host}.'
      : 'Cannot reach ${Uri.parse(url).host}.';
}

class AnnasArchieve {
  static const String defaultBaseUrl = 'https://annas-archive.gl';

  AnnasArchieve(
      {String baseUrl = defaultBaseUrl,
      Dio? dio,
      this.browserPageLoader,
      this.preferBrowser = false})
      : baseUrl = normalizeBaseUrl(baseUrl),
        dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            ));

  final String baseUrl;
  final Dio dio;
  final bool preferBrowser;
  final Future<String> Function(String)? browserPageLoader;

  static String normalizeBaseUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        RegExp(r'\s|%').hasMatch(uri.host) ||
        uri.userInfo.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException(
          'Enter an HTTPS website address without a path.');
    }
    return uri.origin;
  }

  String resolveUrl(String value) {
    final uri = Uri.parse(value);
    const archiveHosts = {
      'annas-archive.org',
      'annas-archive.se',
      'annas-archive.li',
      'annas-archive.gl',
      'annas-archive.pk',
      'annas-archive.gd',
    };
    if (!uri.hasAuthority || archiveHosts.contains(uri.host)) {
      final path = '${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}'
          '${uri.hasFragment ? '#${uri.fragment}' : ''}';
      return Uri.parse(baseUrl).resolve(path).toString();
    }
    return value;
  }

  static bool _isBrowserCheck(String html) {
    final title = parse(html).querySelector('title')?.text.toLowerCase() ?? '';
    return title.contains('ddos-guard') ||
        title.contains('just a moment') ||
        html.contains('/.well-known/ddos-guard/js-challenge/') ||
        html.contains('/cdn-cgi/challenge-platform/');
  }

  static bool isArchivePage(String html) =>
      !_isBrowserCheck(html) &&
      parse(html).querySelector('.main-inner') != null;

  static bool matchesRequestedPage(String requestedUrl, String currentUrl) {
    final expected = Uri.tryParse(requestedUrl);
    final actual = Uri.tryParse(currentUrl);
    if (expected == null ||
        actual == null ||
        !expected.hasAuthority ||
        !actual.hasAuthority ||
        expected.scheme != 'https' ||
        actual.scheme != 'https' ||
        expected.origin != actual.origin ||
        expected.path != actual.path) {
      return false;
    }
    Map<String, List<String>> searchParameters(Uri uri) => {
          for (final entry in uri.queryParametersAll.entries)
            if (entry.key != 'check' &&
                entry.value.any((value) => value.isNotEmpty))
              entry.key: (entry.value
                  .map((value) =>
                      entry.key == 'q' ? value.trim().toLowerCase() : value)
                  .toList()
                ..sort()),
        };
    final requested = searchParameters(expected);
    final current = searchParameters(actual);
    if (requested.length != current.length) return false;
    for (final entry in requested.entries) {
      final values = current[entry.key];
      if (values == null || values.length != entry.value.length) return false;
      for (var i = 0; i < values.length; i++) {
        if (values[i] != entry.value[i]) return false;
      }
    }
    return true;
  }

  Future<String> _getPage(String url, String? pageHtml) async {
    if (pageHtml != null) return pageHtml;
    if (preferBrowser && browserPageLoader != null)
      return _loadBrowserPage(url);
    try {
      final response = await dio.get<String>(url,
          options: Options(
              headers: defaultDioHeaders, responseType: ResponseType.plain));
      final html = response.data ?? '';
      if (_isBrowserCheck(html)) {
        return _loadBrowserPage(url);
      }
      return html;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 403 || status == 429 || status == 503) {
        return _loadBrowserPage(url, cause: error);
      }
      if (status != null && status >= 500) {
        throw ArchiveRequestException(url: url, cause: error);
      }
      if ({
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.unknown
      }.contains(error.type)) {
        throw ArchiveRequestException(url: url, cause: error);
      }
      rethrow;
    }
  }

  Future<String> _loadBrowserPage(String url, {Object? cause}) async {
    final loader = browserPageLoader;
    if (loader != null) {
      try {
        final html = await loader(url);
        if (isArchivePage(html)) return html;
      } catch (error) {
        cause = error;
      }
    }
    throw ArchiveRequestException(url: url, needsBrowser: true, cause: cause);
  }

  Map<String, dynamic> defaultDioHeaders = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
  };

  String getMd5(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    return pathSegments.isNotEmpty ? pathSegments.last : '';
  }

  String getFormat(String info) {
    final infoLower = info.toLowerCase();
    if (infoLower.contains('pdf')) {
      return 'pdf';
    } else if (infoLower.contains('cbr')) {
      return "cbr";
    } else if (infoLower.contains('cbz')) {
      return "cbz";
    }
    return "epub";
  }

  // Helper function to safely parse potential NaN/Infinity to prevent crash
  // This is a generic safeguard for the third type of error you received.
  dynamic _safeParse(dynamic value) {
    if (value is String) {
      if (value.toLowerCase() == 'nan' || value.toLowerCase() == 'infinity') {
        return null; // Return null or 0 instead of throwing an error
      }
      return value;
    }
    return value;
  }

  // --------------------------------------------------------------------
  // _parser FUNCTION (Search Results - Fixed nth-of-type issue)
  // --------------------------------------------------------------------
  List<BookData> _parser(resData, String fileType) {
    var document = parse(resData.toString());

    var bookContainers =
        document.querySelectorAll('div.flex.pt-3.pb-3.border-b');

    List<BookData> bookList = [];

    for (var container in bookContainers) {
      final mainLinkElement =
          container.querySelector('a.line-clamp-\\[3\\].js-vim-focus');
      final thumbnailElement = container.querySelector('a[href^="/md5/"] img');

      if (mainLinkElement == null ||
          mainLinkElement.attributes['href'] == null) {
        continue;
      }

      final String title = mainLinkElement.text.trim();
      final String link = resolveUrl(mainLinkElement.attributes['href']!);
      final String md5 = getMd5(mainLinkElement.attributes['href']!);
      final String? thumbnail = thumbnailElement?.attributes['src'];

      // Fix: Use sequential traversal instead of :nth-of-type
      dom.Element? authorLinkElement = mainLinkElement.nextElementSibling;
      dom.Element? publisherLinkElement = authorLinkElement?.nextElementSibling;

      if (authorLinkElement?.attributes['href']?.startsWith('/search?q=') !=
          true) {
        authorLinkElement = null;
      }
      if (publisherLinkElement?.attributes['href']?.startsWith('/search?q=') !=
          true) {
        publisherLinkElement = null;
      }

      final String? authorRaw = authorLinkElement?.text.trim();
      final String? author = (authorRaw != null && authorRaw.contains('icon-'))
          ? authorRaw.split(' ').skip(1).join(' ').trim()
          : authorRaw;

      final String? publisher = publisherLinkElement?.text.trim();

      final infoElement = container.querySelector('div.text-gray-800');
      // No need for _safeParse here if we only treat info as a string
      final String? info = infoElement?.text.trim();

      final bool hasMatchingFileType = fileType.isEmpty
          ? (info?.contains(
                  RegExp(r'(PDF|EPUB|CBR|CBZ)', caseSensitive: false)) ==
              true)
          : info?.toLowerCase().contains(fileType.toLowerCase()) == true;

      if (hasMatchingFileType) {
        final BookData book = BookData(
          title: title,
          author: author?.isEmpty == true ? "unknown" : author,
          thumbnail: thumbnail,
          link: link,
          md5: md5,
          publisher: publisher?.isEmpty == true ? "unknown" : publisher,
          info: info,
        );
        bookList.add(book);
      }
    }
    return bookList;
  }
  // --------------------------------------------------------------------

  // --------------------------------------------------------------------
  // _bookInfoParser FUNCTION (Detail Page - Fixed 'unable to get data' error)
  // --------------------------------------------------------------------
  Future<BookInfoData?> _bookInfoParser(resData, url) async {
    var document = parse(resData.toString());
    final main = document.querySelector('div.main-inner');
    if (main == null) return null;

    // --- Mirror Link Extraction ---
    String? mirror;
    final slowDownloadLinks =
        main.querySelectorAll('ul.list-inside a[href*="/slow_download/"]');
    if (slowDownloadLinks.isNotEmpty &&
        slowDownloadLinks.first.attributes['href'] != null) {
      mirror = resolveUrl(slowDownloadLinks.first.attributes['href']!);
    }
    // --------------------------------

    // --- Core Info Extraction ---

    // Title
    final titleElement = main.querySelector('div.font-semibold.text-2xl');

    // Author
    final authorLinkElement =
        main.querySelector('a[href^="/search?q="].text-base');

    // Publisher
    dom.Element? publisherLinkElement = authorLinkElement?.nextElementSibling;
    if (publisherLinkElement?.localName != 'a' ||
        publisherLinkElement?.attributes['href']?.startsWith('/search?q=') !=
            true) {
      publisherLinkElement = null;
    }

    // Thumbnail
    final thumbnailElement = main.querySelector('div[id^="list_cover_"] img');

    // Info/Metadata
    final infoElement = main.querySelector('div.text-gray-800');

    // Description
    dom.Element? descriptionElement;
    final descriptionLabel = main.querySelector(
        'div.js-md5-top-box-description div.text-xs.text-gray-500.uppercase');

    if (descriptionLabel?.text.trim().toLowerCase() == 'description') {
      descriptionElement = descriptionLabel?.nextElementSibling;
    }
    String description = descriptionElement?.text.trim() ?? " ";

    if (titleElement == null) {
      return null;
    }

    final String title = titleElement.text.trim().split('<span')[0].trim();
    final String author = authorLinkElement?.text.trim() ?? "unknown";
    final String? thumbnail = thumbnailElement?.attributes['src'];

    final String publisher = publisherLinkElement?.text.trim() ?? "unknown";
    // NOTE: If you extract any numeric data from the 'info' string later in your app (e.g., file size or page count)
    // and attempt to convert it to an integer or double, that's where you should use _safeParse.
    final String info = infoElement?.text.trim() ?? '';

    return BookInfoData(
      title: title,
      author: author,
      thumbnail: thumbnail,
      publisher: publisher,
      info: info,
      link: url,
      md5: getMd5(url),
      format: getFormat(info),
      mirror: mirror,
      description: description,
    );
  }
  // --------------------------------------------------------------------

  String urlEncoder(
      {required String searchQuery,
      required String content,
      required String sort,
      required String fileType,
      required bool enableFilters,
      String language = ''}) {
    return Uri.parse('$baseUrl/search').replace(queryParameters: {
      'q': searchQuery,
      if (enableFilters && language.isNotEmpty) 'lang': language,
      if (enableFilters && content.isNotEmpty) 'content': content,
      if (enableFilters && fileType.isNotEmpty) 'ext': fileType,
      if (enableFilters && sort.isNotEmpty) 'sort': sort,
    }).toString();
  }

  Future<List<BookData>> searchBooks(
      {required String searchQuery,
      String content = "",
      String sort = "",
      String fileType = "",
      bool enableFilters = true,
      String language = '',
      String? pageHtml}) async {
    try {
      final String encodedURL = urlEncoder(
          searchQuery: searchQuery,
          content: content,
          sort: sort,
          fileType: fileType,
          enableFilters: enableFilters,
          language: language);

      return _parser(await _getPage(encodedURL, pageHtml), fileType);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      rethrow;
    }
  }

  Future<BookInfoData> bookInfo({required String url, String? pageHtml}) async {
    url = resolveUrl(url);
    try {
      BookInfoData? data =
          await _bookInfoParser(await _getPage(url, pageHtml), url);
      if (data != null) {
        // Here's where you might use _safeParse if the API returned a numeric field
        // E.g., int pages = _safeParse(data.pages).toInt();
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
