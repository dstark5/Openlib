// lib/services/google_suggest_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSuggestApi {
  // Base URL for the Google Autocomplete service
  static const String _baseUrl = 'https://suggestqueries.google.com/complete/search'; 

  /// Fetches a list of search suggestions using the Google Autocomplete endpoint.
  Future<List<String>> fetchSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    // Construct the URL with required parameters
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'client': 'firefox', // Client parameter for a clean array response
      'q': cleanQuery, 
    }); 

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Google Suggest returns a JSON array. We expect the suggestions to be the second element (index 1).
        final List data = jsonDecode(response.body);
        
        if (data.length > 1 && data[1] is List) {
          final List rawSuggestions = data[1];
          
          return rawSuggestions
              .map<String>((item) => item.toString())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        return [];
      } else {
        print('Google Suggest Error: Status ${response.statusCode}');
        return ['Suggestion Error'];
      }
    } catch (e) {
      print('Network Error: $e');
      return ['Network Error'];
    }
  }
}