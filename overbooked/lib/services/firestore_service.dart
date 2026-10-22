import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/reading_stats.dart';

/// Handles all Firestore read/write operations for the Overbooked app.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection References ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _booksRef(String userId) =>
      _db.collection('users').doc(userId).collection('books');

  DocumentReference<Map<String, dynamic>> _statsRef(String userId) =>
      _db.collection('users').doc(userId).collection('stats').doc('summary');

  // ── Books ──────────────────────────────────────────────────────────────────

  /// Stream of the user's books, ordered by most recently updated.
  Stream<List<Book>> booksStream(String userId) => _booksRef(userId)
      .orderBy('updatedAt', descending: true)
      .withConverter<Book>(
        fromFirestore: (snap, _) => Book.fromFirestore(snap),
        toFirestore: (book, _) => book.toFirestore(),
      )
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  /// Adds (or overwrites) a book document in the user's collection.
  Future<void> addBook(String userId, Book book) =>
      _booksRef(userId).doc(book.id).set(book.toFirestore());

  /// Updates only the `status` (and `completedAt` if applicable).
  Future<void> updateBookStatus(
    String userId,
    String bookId,
    String status,
  ) {
    final updates = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == BookStatus.read) {
      // Set completedAt so the Cloud Function can calculate pagesReadThisMonth.
      updates['completedAt'] = FieldValue.serverTimestamp();
    } else {
      // Clear completedAt if moving off the 'read' shelf.
      updates['completedAt'] = null;
    }

    return _booksRef(userId).doc(bookId).update(updates);
  }

  /// Updates only the page count for a book.
  Future<void> updatePageCount(
    String userId,
    String bookId,
    int pageCount,
  ) =>
      _booksRef(userId).doc(bookId).update({
        'pageCount': pageCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// Permanently removes a book from the user's collection.
  Future<void> deleteBook(String userId, String bookId) =>
      _booksRef(userId).doc(bookId).delete();

  // ── Stats ──────────────────────────────────────────────────────────────────

  /// Stream of the user's aggregated reading statistics.
  /// Emits [ReadingStats.empty()] if the summary document doesn't exist yet.
  Stream<ReadingStats> statsStream(String userId) => _statsRef(userId)
      .snapshots()
      .map((snap) => ReadingStats.fromFirestore(snap));
}
