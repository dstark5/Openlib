import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/download_file.dart';

void main() {
  test(
      'download candidates exclude archive navigation at every supported origin',
      () {
    expect(
        orderDownloadMirrors([
          'https://annas-archive.org/md5/book',
          'https://annas-archive.se/slow_download/book',
          'https://annas-archive.gl/search',
          'https://annas-archive.pk/md5/book',
          'https://annas-archive.gd/md5/book',
          'https://mirror.example/md5/book',
          'https://1lib.sk/book',
          'https://files.example/book.epub',
          'https://ipfs.example/ipfs/book',
        ], archiveBaseUrl: 'https://mirror.example'),
        [
          'https://ipfs.example/ipfs/book',
          'https://files.example/book.epub',
        ]);
  });
}
