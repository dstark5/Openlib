import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/ui/results_page.dart';
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/state/state.dart'
    show
        searchQueryProvider,
        selectedTypeState,
        selectedSortState,
        typeValues,
        sortValues;

import 'components/snack_bar_widget.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({Key? key}) : super(key: key);

  void onSubmit(BuildContext context, WidgetRef ref) {
    if(ref.read(searchQueryProvider).isNotEmpty) {
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) {
        return ResultPage(
          searchQuery: ref.read(searchQueryProvider),
        );
      }
      ));
    }
    else{
      showSnackBar(context: context, message: 'Search field is empty');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dropdownTypeValue = ref.watch(selectedTypeState);
    final dropdownSortValue = ref.watch(selectedSortState);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleText("Search"),
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7, top: 10),
              child: TextField(
                showCursor: true,
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.only(right: 5),
                    color: Theme.of(context).colorScheme.secondary,
                    icon: const Icon(
                      Icons.search,
                      size: 23,
                    ),
                    onPressed: () => onSubmit(context, ref),
                  ),
                  filled: true,
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                  hintText: "Search",
                  fillColor: Theme.of(context).colorScheme.primary,
                ),
                onSubmitted: (String value) => onSubmit(context, ref),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onChanged: (String value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7, top: 19),
              child: SizedBox(
                width: 250,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  value: dropdownTypeValue,
                  items: typeValues.keys
                      .toList()
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    ref.read(selectedTypeState.notifier).state = val ?? '';
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7, top: 19),
              child: SizedBox(
                width: 210,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Sort by',
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  value: dropdownSortValue,
                  items: sortValues.keys
                      .toList()
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    ref.read(selectedSortState.notifier).state = val ?? '';
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
