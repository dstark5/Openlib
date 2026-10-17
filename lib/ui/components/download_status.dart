import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/book_download.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/webview_page.dart';

Future<void> openDownloadWebsite(BuildContext context, WidgetRef ref) async {
  final job = ref.read(bookDownloadProvider);
  if (job == null || job.phase != DownloadPhase.needsWebsite) return;
  final mirrors = await Navigator.push<List<String>>(context,
      MaterialPageRoute(builder: (_) => Webview(url: job.book.mirror!)));
  if (mirrors != null && ref.context.mounted) {
    unawaited(
        ref.read(bookDownloadProvider.notifier).continueWithMirrors(mirrors));
  }
}

void showDownloadProgress(BuildContext context) {
  showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(builder: (context, ref, _) {
            final job = ref.watch(bookDownloadProvider);
            return AlertDialog(
              title: const Text('Download'),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (job != null) Text(job.book.title),
                    const SizedBox(height: 12),
                    const DownloadStatusBar(compact: true)
                  ]),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(job?.active == true ? 'Hide' : 'Done'))
              ],
            );
          }));
}

class BookDownloadButton extends ConsumerWidget {
  const BookDownloadButton({super.key, required this.book});
  final BookInfoData book;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(bookDownloadProvider)?.active == true;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 21),
        child: FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary),
          onPressed: busy
              ? null
              : () async {
                  if (book.mirror == null || book.mirror!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No download links available.')));
                    return;
                  }
                  final showWindows = ref.read(showDownloadWindowsProvider);
                  unawaited(ref
                      .read(bookDownloadProvider.notifier)
                      .start(book, showWebsite: showWindows));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Download started in background'),
                      duration: Duration(seconds: 2)));
                  if (showWindows) {
                    await openDownloadWebsite(context, ref);
                    if (context.mounted) showDownloadProgress(context);
                  }
                },
          child: Text(busy ? 'Download in progress' : 'Add To My Library'),
        ));
  }
}

class DownloadStatusBar extends ConsumerWidget {
  const DownloadStatusBar({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(bookDownloadProvider);
    if (job == null) return const SizedBox.shrink();
    final label = switch (job.phase) {
      DownloadPhase.resolving => 'Preparing download',
      DownloadPhase.needsWebsite => 'Website check needed',
      DownloadPhase.downloading => job.total > 0
          ? 'Downloading ${(job.received / job.total * 100).clamp(0, 100).round()}%'
          : 'Downloading',
      DownloadPhase.verifying => 'Checking downloaded file',
      DownloadPhase.complete => 'Added to My Library',
      DownloadPhase.failed => job.message ?? 'Download failed',
      DownloadPhase.cancelled => 'Download cancelled',
    };
    final controller = ref.read(bookDownloadProvider.notifier);
    final color = Theme.of(context).colorScheme.secondary;
    return SafeArea(
        top: false,
        bottom: !compact,
        child: Material(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(
                    child: InkWell(
                        onTap: compact
                            ? null
                            : () => showDownloadProgress(context),
                        child: Text('$label · ${job.book.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12)))),
                if (job.phase == DownloadPhase.needsWebsite)
                  TextButton(
                      style: TextButton.styleFrom(foregroundColor: color),
                      onPressed: () => openDownloadWebsite(context, ref),
                      child: const Text('Continue')),
                IconButton(
                    tooltip: job.active ? 'Cancel download' : 'Dismiss',
                    icon: const Icon(Icons.close),
                    onPressed:
                        job.active ? controller.cancel : controller.dismiss),
              ]),
              if ({
                DownloadPhase.resolving,
                DownloadPhase.downloading,
                DownloadPhase.verifying
              }.contains(job.phase))
                LinearProgressIndicator(
                    minHeight: 2,
                    color: color,
                    value:
                        job.phase == DownloadPhase.downloading && job.total > 0
                            ? (job.received / job.total).clamp(0.0, 1.0)
                            : null),
            ]),
          ),
        ));
  }
}
