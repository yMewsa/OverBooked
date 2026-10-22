import 'package:cloud_firestore/cloud_firestore.dart';

/// Defines the valid reading status values stored in Firestore.
abstract final class BookStatus {
  static const String wantToRead = 'want_to_read';
  static const String reading = 'reading';
  static const String read = 'read';
}

/// Represents a single book in the user's bookshelf.
class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final int? pageCount;
  final String status;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Book({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.pageCount,
    required this.status,
    required this.updatedAt,
    this.completedAt,
  });

  // ── Display Helpers ────────────────────────────────────────────────────────

  /// Returns the Portuguese label for this book's shelf status.
  String get statusLabel => switch (status) {
        BookStatus.reading => 'Lendo agora',
        BookStatus.wantToRead => 'Quero ler',
        BookStatus.read => 'Lidos e resenhados',
        _ => 'Desconhecido',
      };

  /// Returns authors joined by a comma, or "Autor desconhecido" if empty.
  String get authorsDisplay =>
      authors.isEmpty ? 'Autor desconhecido' : authors.join(', ');

  /// Returns formatted page count or a localized fallback string.
  String get pageCountDisplay =>
      pageCount != null ? '$pageCount págs.' : 'Desconhecido';

  // ── Serialization ──────────────────────────────────────────────────────────

  /// Creates a [Book] from a Firestore document snapshot.
  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Book(
      id: doc.id,
      title: data['title'] as String? ?? 'Sem título',
      authors: List<String>.from(data['authors'] as List? ?? []),
      coverUrl: data['coverUrl'] as String?,
      pageCount: data['pageCount'] as int?,
      status: data['status'] as String? ?? BookStatus.wantToRead,
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a [Book] from a Google Books API volume item JSON object.
  factory Book.fromGoogleBooks(Map<String, dynamic> json) {
    final info = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks =
        info['imageLinks'] as Map<String, dynamic>? ?? {};

    // Prefer thumbnail, fall back to smallThumbnail; upgrade to https.
    String? rawCover =
        imageLinks['thumbnail'] as String? ??
        imageLinks['smallThumbnail'] as String?;
    if (rawCover != null) {
      rawCover = rawCover.replaceFirst('http://', 'https://');
    }

    return Book(
      id: json['id'] as String? ?? '',
      title: info['title'] as String? ?? 'Sem título',
      authors: List<String>.from(info['authors'] as List? ?? []),
      coverUrl: rawCover,
      pageCount: info['pageCount'] as int?,
      status: BookStatus.wantToRead,
      updatedAt: DateTime.now(),
    );
  }

  /// Converts this [Book] to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'authors': authors,
        'coverUrl': coverUrl,
        'pageCount': pageCount,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };

  // ── Immutable Updates ──────────────────────────────────────────────────────

  Book copyWith({
    String? id,
    String? title,
    List<String>? authors,
    String? coverUrl,
    int? pageCount,
    String? status,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        authors: authors ?? this.authors,
        coverUrl: coverUrl ?? this.coverUrl,
        pageCount: pageCount ?? this.pageCount,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt:
            clearCompletedAt ? null : completedAt ?? this.completedAt,
      );

  @override
  String toString() => 'Book(id: $id, title: $title, status: $status)';
}
