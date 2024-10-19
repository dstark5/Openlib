// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

class CategoryBookData {
  final String? title;  
  final String? thumbnail;
  final String? link;
  CategoryBookData({this.title, this.thumbnail, this.link});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryBookData &&
        other.title == title &&
        other.thumbnail == thumbnail &&
        other.link == link;
  }

  @override
  int get hashCode {
    return title.hashCode ^ thumbnail.hashCode ^ link.hashCode; // Using XOR to combine hash codes
  }
  }


String baseUrl = "https://www.goodreads.com/";

class SubCategoriesTypeList {
   List<CategoryBookData>_parser(data) {
    var document = parse(data.toString());
    var categoryList = document.querySelectorAll('.listImgs a');
    List<CategoryBookData> categoriesBooks = [];
    for (var element in categoryList) {
      if (element.querySelector('img"]')?.attributes['title'] != null &&
          element.querySelector('img')?.attributes['src'] != null) {
        String? title = element.querySelector('img')?.attributes['title'];
        String? thumbnail = element.querySelector('img')?.attributes['src'];
        String? link = element.querySelector('a')?.attributes['herf']!;
        categoriesBooks.add(  CategoryBookData(
              title: title
                  .toString()
                  .trim(),
              thumbnail: thumbnail
                  .toString()
                  .replaceAll("._SY75_.", "._SY225_.")
                  .replaceAll("._SX50_.", "._SX148_."),
              link : link
                  .toString(),
          ),
        );
      }
    }
    return categoriesBooks;
  }

  Future<List<CategoryBookData>> categoriesBooks({required String url}) async {
    try {
      final dio = Dio();
      final response = await dio.get('$baseUrl$url',
          options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20)));
      final response1 = await dio.get('$baseUrl$url?page=2',
          options: Options(
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20)));
      return _parser('${response.data.toString()}${response1.data.toString()}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      rethrow;
    }
  }
}

