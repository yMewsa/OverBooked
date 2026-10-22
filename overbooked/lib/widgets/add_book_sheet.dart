import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/book.dart';
import '../providers/bookshelf_provider.dart';
import '../theme/app_theme.dart';

/// Bottom sheet for adding a searched book to one of the three shelves.
class AddBookSheet extends StatelessWidget {
  final Book book;
  final String userId;

  const AddBookSheet({
    super.key,
    required this.book,
    required this.userId,
  });

  void _addBook(BuildContext context, String status) {
    final newBook = book.copyWith(
      id: const Uuid().v4(),
      status: status,
      updatedAt: DateTime.now(),
      completedAt: status == BookStatus.read ? DateTime.now() : null,
    );

    context.read<BookshelfProvider>().addBook(newBook, userId);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📚 "${book.title}" adicionado à estante!',
          maxLines: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Book info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCover(),
                const SizedBox(width: 16),
                Expanded(child: _buildBookDetails(context)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Shelf selection buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.import_contacts_outlined, size: 18),
                label: const Text('Adicionar a Lendo'),
                onPressed: () => _addBook(context, BookStatus.reading),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.bookmark_border, size: 18),
                label: const Text('Adicionar a Quero Ler'),
                onPressed: () => _addBook(context, BookStatus.wantToRead),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Marcar como Lido'),
                onPressed: () => _addBook(context, BookStatus.read),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.success,
                  side: const BorderSide(color: AppTheme.success),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 100,
        child: book.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: book.coverUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.accent.withOpacity(0.12),
      child: const Center(
        child: Icon(Icons.menu_book, size: 28, color: AppTheme.accent),
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          book.authorsDisplay,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          book.pageCountDisplay,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
