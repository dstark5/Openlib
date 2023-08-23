import 'package:flutter/material.dart';
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/state/state.dart' show themeModeProvider;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleText("Settings"),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dark Mode",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Switch(
                        // This bool value toggles the switch.
                        value: ref.watch(themeModeProvider) == ThemeMode.dark,
                        activeColor: Colors.red,
                        onChanged: (bool value) {
                          ref.read(themeModeProvider.notifier).state =
                              value == true ? ThemeMode.dark : ThemeMode.light;
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
