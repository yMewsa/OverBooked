import 'package:flutter/material.dart';

import '../models/book.dart';
import '../theme/app_theme.dart';
import 'book_card.dart';

/// A bookshelf section with a decorative wood-grain divider and a
/// horizontally scrollable list of [BookCard] widgets.
class ShelfSection extends StatelessWidget {
  final String title;
  final List<Book> books;
  final String userId;

  const ShelfSection({
    super.key,
    required this.title,
    required this.books,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 10),
          _buildShelfDivider(),
          const SizedBox(height: 12),
          _buildBookList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Book count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${books.length} ${books.length == 1 ? 'livro' : 'livros'}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Decorative wood-grain shelf divider using a gradient.
  Widget _buildShelfDivider() {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFC4935A),
            Color(0xFF8B5E3C),
            Color(0xFF7A5230),
            Color(0xFF8B5E3C),
            Color(0xFFA0714F),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shelfWood.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(BuildContext context) {
    if (books.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: 210,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (_, index) => BookCard(
          book: books[index],
          userId: userId,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📚', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              'Nenhum livro aqui ainda',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
