import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../services/books_api_service.dart';

/// Manages the user's bookshelf data and Google Books search state.
class BookshelfProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final BooksApiService _booksApiService = BooksApiService();

  List<Book> _books = [];
  List<Book> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<Book>>? _booksSubscription;

  // ── Getters ────────────────────────────────────────────────────────────────

  List<Book> get books => _books;
  List<Book> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Books with status 'reading', ordered by most recently updated.
  List<Book> get readingNow =>
      _books.where((b) => b.status == BookStatus.reading).toList();

  /// Books with status 'want_to_read'.
  List<Book> get wantToRead =>
      _books.where((b) => b.status == BookStatus.wantToRead).toList();

  /// Books with status 'read'.
  List<Book> get read =>
      _books.where((b) => b.status == BookStatus.read).toList();

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Starts listening to the user's Firestore book collection.
  /// Call this once when the user's session begins (e.g., in MainShell).
  void init(String userId) {
    _booksSubscription?.cancel();
    _isLoading = true;

    _booksSubscription = _firestoreService.booksStream(userId).listen(
      (books) {
        _books = books;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage =
            'Não foi possível carregar sua estante. Verifique sua conexão.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Bookshelf Actions ──────────────────────────────────────────────────────

  /// Adds a book to the user's Firestore collection.
  Future<void> addBook(Book book, String userId) async {
    try {
      await _firestoreService.addBook(userId, book);
    } catch (e) {
      _setError('Não foi possível adicionar o livro. Tente novamente.');
    }
  }

  /// Updates a book's reading status on Firestore.
  Future<void> updateBookStatus(
    String bookId,
    String status,
    String userId,
  ) async {
    try {
      await _firestoreService.updateBookStatus(userId, bookId, status);
    } catch (e) {
      _setError('Não foi possível mover o livro. Tente novamente.');
    }
  }

  /// Updates the page count for a specific book.
  Future<void> updatePageCount(
    String bookId,
    int pageCount,
    String userId,
  ) async {
    try {
      await _firestoreService.updatePageCount(userId, bookId, pageCount);
    } catch (e) {
      _setError('Não foi possível atualizar as páginas. Tente novamente.');
    }
  }

  /// Removes a book from the user's Firestore collection.
  Future<void> deleteBook(String bookId, String userId) async {
    try {
      await _firestoreService.deleteBook(userId, bookId);
    } catch (e) {
      _setError('Não foi possível remover o livro. Tente novamente.');
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  /// Searches Google Books API for books matching [query].
  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _booksApiService.searchBooks(query);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clears search results and resets the search state.
  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears any stored error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _booksSubscription?.cancel();
    super.dispose();
  }
}
