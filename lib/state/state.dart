// Dart imports:
import 'dart:math';
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
// NOTE: These imports are crucial and must exist in your project structure.
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/files.dart';
import 'package:openlib/services/open_library.dart';
import 'package:openlib/services/goodreads.dart';
import 'package:openlib/services/reader_apps.dart';
import 'package:openlib/services/book_download.dart';
import 'package:openlib/services/archive_download.dart';
import 'package:openlib/services/download_file.dart';
// Assuming OpenLibrary, Goodreads, PenguinRandomHouse, BookDigits, and SubCategoriesTypeList are defined
// or are simple placeholder services/models that work as intended.

MyLibraryDb dataBase = MyLibraryDb.instance;

// ====================================================================
// DROPDOWN/FILTER MAPPING DATA
// ====================================================================

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

// ====================================================================
// ENUMS AND DATA CLASSES
// ====================================================================

enum ProcessState { waiting, running, complete }

enum CheckSumProcessState { waiting, running, failed, success }

class FileName {
  final String md5;
  final String format;

  FileName({required this.md5, required this.format});
}

// ====================================================================
// UI AND SIMPLE STATE PROVIDERS
// ====================================================================

final selectedIndexProvider = StateProvider<int>((ref) => 0);
final homePageSelectedIndexProvider = StateProvider<int>((ref) => 0);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Search Filter States
final selectedTypeState = StateProvider<String>((ref) => "All");
final selectedLanguageState = StateProvider<String>((ref) => '');
final selectedSortState = StateProvider<String>((ref) => "Most Relevant");
final selectedFileTypeState = StateProvider<String>((ref) => "All");
final searchQueryProvider = StateProvider<String>((ref) => "");
final enableFiltersState = StateProvider<bool>((ref) => true);

// Web/Download States
final cookieProvider = StateProvider<String>((ref) => "");
final userAgentProvider = StateProvider<String>((ref) => "");
final archivePageLoaderProvider =
    Provider<Future<String> Function(String)?>((ref) => null);
final archiveBaseUrlProvider =
    StateProvider<String>((ref) => AnnasArchieve.defaultBaseUrl);
// Browser-rendered pages are only kept for the current app session.
final archiveBrowserPagesProvider =
    StateProvider<Map<String, String>>((ref) => {});
final webViewLoadingState = StateProvider.autoDispose<bool>((ref) => true);
final downloadProgressProvider =
    StateProvider.autoDispose<double>((ref) => 0.0);
final mirrorStatusProvider = StateProvider.autoDispose<bool>((ref) => false);
final totalFileSizeInBytes = StateProvider.autoDispose<int>((ref) => 0);
final downloadedFileSizeInBytes = StateProvider.autoDispose<int>((ref) => 0);
final downloadState =
    StateProvider.autoDispose<ProcessState>((ref) => ProcessState.waiting);
final checkSumState = StateProvider.autoDispose<CheckSumProcessState>(
    (ref) => CheckSumProcessState.waiting);
final cancelCurrentDownload = StateProvider<CancelToken>((ref) {
  return CancelToken();
});

// PDF/Epub Reader States
final pdfCurrentPage = StateProvider.autoDispose<int>((ref) => 0);
final totalPdfPage = StateProvider.autoDispose<int>((ref) => 0);
final openPdfWithExternalAppProvider = StateProvider<bool>((ref) => false);
final openEpubWithExternalAppProvider = StateProvider<bool>((ref) => false);
final readerPreferenceProvider =
    StateProvider.family<String, String>((ref, format) => 'internal');
final readerAppsProvider = Provider<ReaderApps>((ref) => const ReaderApps());
final installedReadersProvider = FutureProvider.family<List<ReaderApp>, String>(
    (ref, format) => ref.watch(readerAppsProvider).installedReaders(format));

// ====================================================================
// DERIVED (COMPUTED) STATE PROVIDERS
// ====================================================================

final getTypeValue = Provider.autoDispose<String>((ref) {
  return typeValues[ref.watch(selectedTypeState)] ?? '';
});

final getSortValue = Provider.autoDispose<String>((ref) {
  return sortValues[ref.watch(selectedSortState)] ?? '';
});

final getFileTypeValue = Provider.autoDispose<String>((ref) {
  final selectedFile = ref.watch(selectedFileTypeState);
  return selectedFile == "All" ? '' : selectedFile.toLowerCase();
});

// Helper function to convert bytes to readable file size
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

// ====================================================================
// ASYNCHRONOUS DATA (FUTURE) PROVIDERS
// ====================================================================

// Provider for Trending Books
final getTrendingBooks = FutureProvider<List<TrendingBookData>>((ref) async {
  // NOTE: Assuming TrendingBookData and the service classes exist and are functional
  GoodReads goodReads = GoodReads();
  // Assuming these classes are available from your project imports
  // ignore: prefer_const_constructors
  final penguinTrending = PenguinRandomHouse();
  // ignore: prefer_const_constructors
  final bookDigits = BookDigits();

  List<TrendingBookData> trendingBooks =
      await Future.wait<List<TrendingBookData>>([
    goodReads.trendingBooks(),
    penguinTrending.trendingBooks(),
    // openLibrary.trendingBooks(), // Commented out as in the original
    bookDigits.trendingBooks(),
  ]).then((List<List<TrendingBookData>> listOfData) =>
          listOfData.expand((element) => element).toList());

  if (trendingBooks.isEmpty) {
    throw Exception(
        'Nothing Trending Today :('); // Use Exception instead of String
  }
  trendingBooks.shuffle();
  return trendingBooks;
});

// Provider for Sub Category Books
final getSubCategoryTypeList = FutureProvider.family
    .autoDispose<List<CategoryBookData>, String>((ref, url) async {
  // NOTE: Assuming CategoryBookData and SubCategoriesTypeList exist
  // ignore: prefer_const_constructors
  SubCategoriesTypeList subCategoriesTypeList = SubCategoriesTypeList();
  List<CategoryBookData> subCategories =
      await subCategoriesTypeList.categoriesBooks(url: url);
  List<CategoryBookData> uniqueArray = subCategories.toSet().toList();
  uniqueArray.shuffle();
  return uniqueArray;
});

// Provider for Anna's Archive Search Results
final searchProvider = FutureProvider.family
    .autoDispose<List<BookData>, String>((ref, searchQuery) async {
  if (searchQuery.isEmpty)
    return []; // Return empty list if search query is empty

  var disposed = false;
  ref.onDispose(() => disposed = true);
  final AnnasArchieve annasArchieve = AnnasArchieve(
      baseUrl: ref.watch(archiveBaseUrlProvider),
      browserPageLoader: ref.watch(archivePageLoaderProvider),
      preferBrowser: ref.watch(archivePageLoaderProvider) != null);
  ref.onDispose(() => annasArchieve.dio.close(force: true));
  final url = annasArchieve.urlEncoder(
      searchQuery: searchQuery,
      content: ref.watch(getTypeValue),
      sort: ref.watch(getSortValue),
      fileType: ref.watch(getFileTypeValue),
      enableFilters: ref.watch(enableFiltersState),
      language: ref.watch(selectedLanguageState));
  List<BookData> data = await annasArchieve.searchBooks(
      searchQuery: searchQuery,
      content: ref.watch(getTypeValue),
      sort: ref.watch(getSortValue),
      fileType: ref.watch(getFileTypeValue),
      enableFilters: ref.watch(enableFiltersState),
      language: ref.watch(selectedLanguageState),
      pageHtml: ref.watch(archiveBrowserPagesProvider)[url]);
  if (!disposed) {
    final cache = ref.keepAlive();
    final expiry = Timer(const Duration(minutes: 3), cache.close);
    ref.onDispose(expiry.cancel);
  }
  return data;
});

// Provider for Book Info Details
final bookInfoProvider =
    FutureProvider.family<BookInfoData, String>((ref, url) async {
  final AnnasArchieve annasArchieve = AnnasArchieve(
      baseUrl: ref.watch(archiveBaseUrlProvider),
      browserPageLoader: ref.watch(archivePageLoaderProvider),
      preferBrowser: ref.watch(archivePageLoaderProvider) != null);
  ref.onDispose(() => annasArchieve.dio.close(force: true));
  BookInfoData data = await annasArchieve.bookInfo(
      url: url,
      pageHtml: ref
          .watch(archiveBrowserPagesProvider)[annasArchieve.resolveUrl(url)]);
  return data;
});

// My Library Database Providers
final myLibraryProvider = FutureProvider((ref) async {
  return dataBase.getAll();
});

final checkIdExists =
    FutureProvider.family.autoDispose<bool, String>((ref, id) async {
  return await dataBase.checkIdExists(id);
});

final deleteFileFromMyLib =
    FutureProvider.family<void, FileName>((ref, fileName) async {
  // NOTE: Assuming deleteFileWithDbData is a function in files.dart
  return await deleteFileWithDbData(ref, fileName.md5, fileName.format);
});

final filePathProvider =
    FutureProvider.family<String, String>((ref, fileName) async {
  // NOTE: Assuming getFilePath is a function in files.dart
  String path = await getFilePath(fileName);
  return path;
});

final getBookPosition =
    FutureProvider.family.autoDispose<String?, String>((ref, fileName) async {
  return await dataBase.getBookState(fileName);
});

// ====================================================================
// BOOK STATE PERSISTENCE FUNCTIONS
// ====================================================================

Future<void> savePdfState(String fileName, WidgetRef ref) async {
  String position = ref.watch(pdfCurrentPage).toString();
  await dataBase.saveBookState(fileName, position);
}

Future<void> saveEpubState(
    String fileName, String? position, WidgetRef ref) async {
  String pos = position ?? '';
  await dataBase.saveBookState(fileName, pos);
}

final showDownloadWindowsProvider = StateProvider<bool>((ref) => false);
final StateNotifierProvider<BookDownloadController, BookDownload?>
    bookDownloadProvider =
    StateNotifierProvider<BookDownloadController, BookDownload?>((ref) {
  return BookDownloadController(
    resolve: ArchiveDownload.resolve,
    transfer: (book, mirrors, progress, cancel) => downloadFile(
        mirrors: mirrors,
        archiveBaseUrl: ref.read(archiveBaseUrlProvider),
        md5: book.md5,
        format: book.format!,
        onProgress: progress,
        cancelToken: cancel),
    verify: (book) =>
        verifyFileCheckSum(md5Hash: book.md5, format: book.format!),
    save: (book) async => dataBase.insert(MyBook(
        id: book.md5,
        title: book.title,
        author: book.author,
        thumbnail: book.thumbnail,
        link: book.link,
        publisher: book.publisher,
        info: book.info,
        format: book.format,
        description: book.description)),
    onSaved: (book) {
      ref.invalidate(checkIdExists(book.md5));
      ref.invalidate(myLibraryProvider);
    },
  );
});
