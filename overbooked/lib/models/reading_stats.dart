import 'package:cloud_firestore/cloud_firestore.dart';

/// Aggregated reading statistics for a user, stored in Firestore.
/// Updated automatically by the Cloud Function when a book is marked as read.
class ReadingStats {
  final int booksRead;
  final int pagesRead;
  final int pagesReadThisMonth;
  final DateTime? lastUpdated;

  const ReadingStats({
    required this.booksRead,
    required this.pagesRead,
    required this.pagesReadThisMonth,
    this.lastUpdated,
  });

  /// Returns a zero-value instance used before data is loaded.
  factory ReadingStats.empty() => const ReadingStats(
        booksRead: 0,
        pagesRead: 0,
        pagesReadThisMonth: 0,
      );

  /// Creates [ReadingStats] from a Firestore document snapshot.
  /// Handles the case where the document doesn't exist yet (returns empty).
  factory ReadingStats.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    if (!doc.exists) return ReadingStats.empty();

    final data = doc.data() ?? {};
    return ReadingStats(
      booksRead: (data['booksRead'] as num?)?.toInt() ?? 0,
      pagesRead: (data['pagesRead'] as num?)?.toInt() ?? 0,
      pagesReadThisMonth:
          (data['pagesReadThisMonth'] as num?)?.toInt() ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => {
        'booksRead': booksRead,
        'pagesRead': pagesRead,
        'pagesReadThisMonth': pagesReadThisMonth,
        'lastUpdated': lastUpdated != null
            ? Timestamp.fromDate(lastUpdated!)
            : FieldValue.serverTimestamp(),
      };

  @override
  String toString() =>
      'ReadingStats(booksRead: $booksRead, pagesRead: $pagesRead, '
      'pagesReadThisMonth: $pagesReadThisMonth)';
}
