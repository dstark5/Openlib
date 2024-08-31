// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/files.dart';
import 'package:openlib/services/open_library.dart';

MyLibraryDb dataBase = MyLibraryDb.instance;

//Provider for dropdownbutton in search page

Map<String, String> typeValues = {
  'All': '',
  'Any Books': 'book_any',
  'Unknown Books': 'book_unknown',
  'Fiction Books': 'book_fiction',
  'Non-fiction Books': 'book_nonfiction',
  'Comic Books': 'book_comic',
  'Magazine': 'magazine',
  'Standards Document': 'standards_document',
  'Journal Article': 'journal_article'
};

Map<String, String> sortValues = {
  'Most Relevant': '',
  'Newest': 'newest',
  'Oldest': 'oldest',
  'Largest': 'largest',
  'Smallest': 'smallest',
};

List<String> fileType = ["All", "PDF", "Epub", "Cbr", "Cbz"];

final selectedIndexProvider = StateProvider<int>((ref) => 0);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final selectedTypeState = StateProvider<String>((ref) => "All");

final getTypeValue = Provider.autoDispose<String>((ref) {
  return typeValues[ref.read(selectedTypeState)] ?? '';
});

final selectedSortState = StateProvider<String>((ref) => "Most Relevant");

final getSortValue = Provider.autoDispose<String>((ref) {
  return sortValues[ref.read(selectedSortState)] ?? '';
});

final selectedFileTypeState = StateProvider<String>((ref) => "All");

final getFileTypeValue = Provider.autoDispose<String>((ref) {
  if (ref.read(selectedFileTypeState) == "All") {
    return '';
  }
  return ref.read(selectedFileTypeState).toLowerCase();
});

//searchQueryProvider

final searchQueryProvider = StateProvider<String>((ref) => "");

//Provider for Trending Books

final getTrendingBooks = FutureProvider<List<TrendingBookData>>((ref) async {
  OpenLibrary openLibrary = OpenLibrary();
  GoodReads goodReads = GoodReads();
  PenguinRandomHouse penguinTrending = PenguinRandomHouse();
  List<TrendingBookData> trendingBooks =
      await Future.wait<List<TrendingBookData>>([
    openLibrary.trendingBooks(),
    goodReads.trendingBooks(),
    penguinTrending.trendingBooks()
  ]).then((List<List<TrendingBookData>> listOfData) =>
          listOfData.expand((element) => element).toList());

  trendingBooks.shuffle();
  return trendingBooks;
});

final enableFiltersState = StateProvider<bool>((ref) => true);

//Provider for Trending Books
final searchProvider = FutureProvider.family
    .autoDispose<List<BookData>, String>((ref, searchQuery) async {
  AnnasArchieve annasArchieve = AnnasArchieve();
  List<BookData> data = await annasArchieve.searchBooks(
      searchQuery: searchQuery,
      content: ref.watch(getTypeValue),
      sort: ref.watch(getSortValue),
      fileType: ref.watch(getFileTypeValue),
      enableFilters: ref.watch(enableFiltersState));
  return data;
});

final cookieProvider = StateProvider<String>((ref) => "");
final userAgentProvider = StateProvider<String>((ref) => "");

final webViewLoadingState = StateProvider.autoDispose<bool>((ref) => true);

//Provider for Book Info
final bookInfoProvider =
    FutureProvider.family<BookInfoData, String>((ref, url) async {
  AnnasArchieve annasArchieve = AnnasArchieve();
  BookInfoData data = await annasArchieve.bookInfo(url: url);
  return data;
});

final downloadProgressProvider =
    StateProvider.autoDispose<double>((ref) => 0.0);

final mirrorStatusProvider = StateProvider.autoDispose<bool>((ref) => false);

final totalFileSizeInBytes = StateProvider.autoDispose<int>((ref) => 0);
final downloadedFileSizeInBytes = StateProvider.autoDispose<int>((ref) => 0);

String bytesToFileSize(int bytes) {
  const int decimals = 1;
  const suffixes = ["b", " Kb", "Mb", "Gb", "Tb"];
  if (bytes == 0) return '0${suffixes[0]}';
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

final getTotalFileSize = StateProvider.autoDispose<String>((ref) {
  return bytesToFileSize(ref.watch(totalFileSizeInBytes));
});

final getDownloadedFileSize = StateProvider.autoDispose<String>((ref) {
  return bytesToFileSize(ref.watch(downloadedFileSizeInBytes));
});

final cancelCurrentDownload = StateProvider<CancelToken>((ref) {
  return CancelToken();
});

enum ProcessState { waiting, running, complete }

enum CheckSumProcessState { waiting, running, failed, success }

final downloadState =
    StateProvider.autoDispose<ProcessState>((ref) => ProcessState.waiting);
final checkSumState = StateProvider.autoDispose<CheckSumProcessState>(
    (ref) => CheckSumProcessState.waiting);

final myLibraryProvider = FutureProvider((ref) async {
  return dataBase.getAll();
});

final checkIdExists =
    FutureProvider.family.autoDispose<bool, String>((ref, id) async {
  return await dataBase.checkIdExists(id);
});

class FileName {
  final String md5;
  final String format;

  FileName({required this.md5, required this.format});
}

final deleteFileFromMyLib =
    FutureProvider.family<void, FileName>((ref, fileName) async {
  return await deleteFileWithDbData(ref, fileName.md5, fileName.format);
});

final pdfCurrentPage = StateProvider.autoDispose<int>((ref) => 0);
final totalPdfPage = StateProvider.autoDispose<int>((ref) => 0);

Future<void> savePdfState(String fileName, WidgetRef ref) async {
  String position = ref.watch(pdfCurrentPage).toString();
  await dataBase.saveBookState(fileName, position);
}

Future<void> saveEpubState(
    String fileName, String? position, WidgetRef ref) async {
  String pos = position ?? '';
  await dataBase.saveBookState(fileName, pos);
}

final getBookPosition =
    FutureProvider.family.autoDispose<String?, String>((ref, fileName) async {
  return await dataBase.getBookState(fileName);
});

final openPdfWithExternalAppProvider = StateProvider<bool>((ref) => false);
final openEpubWithExternalAppProvider = StateProvider<bool>((ref) => false);

final filePathProvider =
    FutureProvider.family<String, String>((ref, fileName) async {
  String path = await getFilePath(fileName);
  return path;
});
