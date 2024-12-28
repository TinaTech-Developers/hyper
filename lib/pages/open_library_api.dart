import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenLibraryAPI {
  // Function to fetch books by a search query (e.g., "Flutter")
  Future<List<Map<String, dynamic>>> fetchBooks(String query) async {
    final url =
        Uri.parse('https://openlibrary.org/search.json?q=$query&limit=10');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> books = [];

        for (var item in data['docs']) {
          books.add({
            'title': item['title'],
            'author': item['author_name'] != null
                ? item['author_name'].join(', ')
                : 'Unknown',
            'cover': item['cover_i'] != null
                ? 'https://covers.openlibrary.org/b/id/${item['cover_i']}-L.jpg'
                : 'https://via.placeholder.com/150', // Default cover
            'key':
                item['key'], // The key to create the URL for the book details
          });
        }

        return books;
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      throw Exception('Failed to load books: $e');
    }
  }
}
