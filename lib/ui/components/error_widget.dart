// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/ui/extensions.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/archive_browser_page.dart';
import 'package:openlib/ui/settings_page.dart';

// ignore: must_be_immutable
class CustomErrorWidget extends ConsumerWidget {
  final Object error;
  final StackTrace stackTrace;
  VoidCallback? onRefresh;

  CustomErrorWidget(
      {super.key,
      required this.error,
      required this.stackTrace,
      this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archiveError = error;
    if (archiveError is ArchiveRequestException) {
      return Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(archiveError.needsBrowser ? Icons.public : Icons.wifi_off,
              size: 48, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 20),
          Text(archiveError.needsBrowser ? 'Complete the website check'
              : 'Cannot reach ${Uri.parse(archiveError.url).host}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(archiveError.needsBrowser
              ? 'Open the page below, complete any check, then return the loaded page to Openlib.'
              : 'Try again, or choose an Anna\'s Archive website that opens on your phone.',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (archiveError.needsBrowser) FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary),
            onPressed: () async {
              final html = await Navigator.push<String>(context, MaterialPageRoute(
                builder: (_) => ArchiveBrowserPage(url: archiveError.url)));
              if (!context.mounted || html == null) return;
              ref.read(archiveBrowserPagesProvider.notifier).state = {
                ...ref.read(archiveBrowserPagesProvider), archiveError.url: html,
              };
            },
            child: const Text('Open page in app'),
          ),
          if (onRefresh != null) TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
            onPressed: () {
            final pages = {...ref.read(archiveBrowserPagesProvider)};
            pages.remove(archiveError.url);
            ref.read(archiveBrowserPagesProvider.notifier).state = pages;
            onRefresh?.call();
          }, child: const Text('Try again')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => Scaffold(appBar: AppBar(title: const Text('Settings')),
                body: const SettingsPage()))), child: const Text('Change website')),
        ]),
      ));
    }
    if (error.toString().contains("socketException")) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 200,
            child: SvgPicture.asset(
              'assets/no_internet.svg',
              width: 200,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            "Unable to access internet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: "#4D4D4D".toColor(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 80,
            child: FittedBox(
              fit: BoxFit.none,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    )),
                onPressed: onRefresh,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(21, 9, 21, 9),
                  child: Text('Refresh'),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 150,
            ),
            SizedBox(
              width: 200,
              child: SvgPicture.asset(
                'assets/error_fixing_bugs.svg',
                width: 200,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Something Went Wrong!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
              child: Text(
                "Error",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Text(
                "Stack Trace",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 186, 186),
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text(
                    stackTrace.toString(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
