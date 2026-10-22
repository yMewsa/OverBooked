import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

/// Handles communication with the Google Books REST API.
class BooksApiService {
  static const String _baseUrl =
      'https://www.googleapis.com/books/v1/volumes';

  // NOTE: Add your Google Books API key here for production.
  // Example: static const String _apiKey = 'YOUR_API_KEY';
  // Then append '&key=$_apiKey' to the request URL.
  // Without a key, the API still works but has a lower rate limit.

  /// Searches for books matching [query] using the Google Books API.
  /// Returns an empty list if no results or on network errors.
  Future<List<Book>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': query.trim(),
      'maxResults': '20',
      'printType': 'books',
      'langRestrict': 'pt', // Prefer Portuguese results; remove if unwanted.
    });

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Falha ao buscar livros (código ${response.statusCode}). '
          'Verifique sua conexão.',
        );
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final items = body['items'] as List?;

      if (items == null || items.isEmpty) return [];

      return items
          .cast<Map<String, dynamic>>()
          .map(Book.fromGoogleBooks)
          .where((book) => book.id.isNotEmpty)
          .toList();
    } on http.ClientException {
      throw Exception(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on FormatException {
      throw Exception(
        'Resposta inesperada da API de livros. Tente novamente.',
      );
    }
  }
}
