import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/categories_page.dart';
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/trending_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final List<Widget> _pages = const [
    TrendingPage(),
    GenresPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(homePageSelectedIndexProvider);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleText(selectedIndex == 0 ? "Trending" : "Genres"),
                PelletContainer(
                  selectedIndex: selectedIndex,
                  onTrendingSelected: () => {
                    ref.read(homePageSelectedIndexProvider.notifier).state = 0
                  },
                  onCategoriesSelected: () => {
                    ref.read(homePageSelectedIndexProvider.notifier).state = 1
                  },
                ),
              ],
            ),
          ),
          Expanded(child: _pages[selectedIndex]), // Display the selected page
        ],
      ),
    );
  }
}

class PelletContainer extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onTrendingSelected;
  final VoidCallback onCategoriesSelected;

  const PelletContainer({
    super.key,
    required this.selectedIndex,
    required this.onTrendingSelected,
    required this.onCategoriesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).colorScheme.secondary,
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left Button (Trending)
          Expanded(
            child: GestureDetector(
              onTap: onTrendingSelected,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: TextButton.icon(
                  onPressed: null, // Disable direct onPressed to avoid conflict
                  icon: Icon(
                    Icons.trending_up,
                    color: selectedIndex == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                  label: const Text(''), // Empty label
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(
            width: 0,
            thickness: 1,
            color: Colors.grey,
          ),
          // Right Button (Categories)
          Expanded(
            child: GestureDetector(
              onTap: onCategoriesSelected,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: TextButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Icons.dashboard_rounded,
                    color: selectedIndex == 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                  label: const Text(''), // Empty label
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
