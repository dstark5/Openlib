// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; // For Timer/Debounce
import 'package:http/http.dart' as http; // Required for the API calls (ensure package is installed)

// Project imports:
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/results_page.dart';
import 'components/snack_bar_widget.dart';
// Import the new API Service (adjust path as necessary)
import 'package:openlib/services/google_suggest_api.dart'; 

import 'package:openlib/state/state.dart'
    show
        searchQueryProvider,
        selectedTypeState,
        selectedSortState,
        selectedFileTypeState,
        typeValues,
        fileType,
        sortValues,
        enableFiltersState;

// ====================================================================
// Suggestion Providers (New)
// ====================================================================

// Provider to hold the list of suggestions
final searchSuggestionProvider = StateProvider<List<String>>((ref) => []);
// Provider to show/hide the loading indicator
final suggestionsLoadingProvider = StateProvider<bool>((ref) => false);


// ====================================================================
// SearchPage Implementation (Stateful Conversion for API & Debounce)
// ====================================================================

class SearchPage extends ConsumerStatefulWidget { // <--- CONVERTED TO STATEFUL
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  Timer? _debounce;
  late final TextEditingController _searchController; 
  final GoogleSuggestApi _apiService = GoogleSuggestApi(); // Instantiate API service

  @override
  void initState() {
    super.initState();
    // Initialize controller with current state value
    _searchController = TextEditingController(text: ref.read(searchQueryProvider));
    
    // Listener to update the TextField when state changes (e.g., when a suggestion is tapped)
    ref.listenManual(searchQueryProvider, (previous, next) {
      if (_searchController.text != next) {
        _searchController.text = next;
        // Move cursor to the end
        _searchController.selection = TextSelection.fromPosition(TextPosition(offset: next.length));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  
  // *** API LOGIC ***
  Future<void> _fetchSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      ref.read(searchSuggestionProvider.notifier).state = [];
      return;
    }

    ref.read(suggestionsLoadingProvider.notifier).state = true;
    
    // Call the Google Suggest API function
    final realSuggestions = await _apiService.fetchSuggestions(cleanQuery);

    ref.read(searchSuggestionProvider.notifier).state = realSuggestions;
    ref.read(suggestionsLoadingProvider.notifier).state = false;
  }
  // *****************

  void _onSearchQueryChanged(String value) {
    // 1. Update the Riverpod state immediately
    ref.read(searchQueryProvider.notifier).state = value;

    // 2. Debounce the API call to limit requests while the user is typing
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(value);
    });
  }

  void onSubmit(BuildContext context) {
    final searchQuery = ref.read(searchQueryProvider);
    if (searchQuery.isNotEmpty) {
      // Clear suggestions list before navigating
      ref.read(searchSuggestionProvider.notifier).state = [];
      ref.read(enableFiltersState.notifier).state = true;
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return ResultPage(searchQuery: searchQuery);
      }));
    } else {
      showSnackBar(context: context, message: 'Search field is empty');
    }
  }

  @override
  Widget build(BuildContext context) { // WidgetRef is available via ConsumerState
    final dropdownTypeValue = ref.watch(selectedTypeState);
    final dropdownSortValue = ref.watch(selectedSortState);
    final dropDownFileTypeValue = ref.watch(selectedFileTypeState);
    
    // Watch suggestion states
    final suggestions = ref.watch(searchSuggestionProvider); // The list of titles
    final isLoadingSuggestions = ref.watch(suggestionsLoadingProvider); // Loading state

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleText("Search"),
            // Search Input Field
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7, top: 10),
              child: TextField(
                controller: _searchController, // <--- Added controller
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
                    icon: isLoadingSuggestions // Show loading spinner if fetching suggestions
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          )
                        : const Icon(
                            Icons.search,
                            size: 23,
                          ),
                    onPressed: () => onSubmit(context), // <--- Simplified call
                  ),
                  filled: true,
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                  hintText: "Search",
                  fillColor: Theme.of(context).colorScheme.primary,
                ),
                onSubmitted: (String value) => onSubmit(context),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onChanged: _onSearchQueryChanged, // <--- Calls the debounced function
              ),
            ),
            
            // --- Suggestions List (NEW) ---
            if (suggestions.isNotEmpty && _searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          suggestion,
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        leading: const Icon(Icons.book, size: 18),
                        onTap: () {
                          // 1. Update the state with the selected suggestion
                          ref.read(searchQueryProvider.notifier).state = suggestion;
                          
                          // 2. Clear the suggestion list
                          ref.read(searchSuggestionProvider.notifier).state = [];
                          
                          // 3. Immediately perform search
                          onSubmit(context);
                        },
                      );
                    },
                  ),
                ),
              ),
            // -----------------------------

            // Dropdown Filters (Unchanged)
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
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7, top: 19),
              child: SizedBox(
                width: 165,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'File type',
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
                  value: dropDownFileTypeValue,
                  items: fileType.map<DropdownMenuItem<String>>((String value) {
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
                    ref.read(selectedFileTypeState.notifier).state =
                        val ?? 'All';
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}