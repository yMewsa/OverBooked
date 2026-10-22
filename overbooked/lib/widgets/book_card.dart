import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/bookshelf_provider.dart';
import '../theme/app_theme.dart';
import 'edit_pages_sheet.dart';

/// A compact vertical book card for use inside shelf rows.
///
/// Displays the cover, title, authors, page count badge, and a context menu
/// (3 dots) that allows shelf management and page editing.
class BookCard extends StatelessWidget {
  final Book book;
  final String userId;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverWithMenu(context),
            _buildBookInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverWithMenu(BuildContext context) {
    return Stack(
      children: [
        // Book cover
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            width: 100,
            height: 130,
            child: book.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: book.coverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildCoverPlaceholder(),
                    errorWidget: (_, __, ___) => _buildCoverPlaceholder(),
                  )
                : _buildCoverPlaceholder(),
          ),
        ),
        // 3-dot menu overlay
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _showContextMenu(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.65),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.more_vert,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: AppTheme.accent.withOpacity(0.12),
      child: const Center(
        child: Icon(Icons.menu_book, size: 36, color: AppTheme.accent),
      ),
    );
  }

  Widget _buildBookInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            book.authorsDisplay,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          // Page count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              book.pageCountDisplay,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final provider = context.read<BookshelfProvider>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ContextMenuSheet(
        book: book,
        userId: userId,
        provider: provider,
      ),
    );
  }
}

// ── Context Menu Sheet ─────────────────────────────────────────────────────────

class _ContextMenuSheet extends StatelessWidget {
  final Book book;
  final String userId;
  final BookshelfProvider provider;

  const _ContextMenuSheet({
    required this.book,
    required this.userId,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            if (book.status != BookStatus.reading)
              _MenuItem(
                icon: Icons.import_contacts_outlined,
                label: 'Mover para Lendo',
                onTap: () {
                  provider.updateBookStatus(book.id, BookStatus.reading, userId);
                  Navigator.pop(context);
                },
              ),
            if (book.status != BookStatus.wantToRead)
              _MenuItem(
                icon: Icons.bookmark_border,
                label: 'Mover para Quero Ler',
                onTap: () {
                  provider.updateBookStatus(
                      book.id, BookStatus.wantToRead, userId);
                  Navigator.pop(context);
                },
              ),
            if (book.status != BookStatus.read)
              _MenuItem(
                icon: Icons.check_circle_outline,
                label: 'Marcar como Lido',
                iconColor: AppTheme.success,
                onTap: () {
                  provider.updateBookStatus(book.id, BookStatus.read, userId);
                  Navigator.pop(context);
                },
              ),
            _MenuItem(
              icon: Icons.edit_note_outlined,
              label: 'Editar nº de páginas',
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppTheme.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) =>
                      EditPagesSheet(book: book, userId: userId),
                );
              },
            ),
            _MenuItem(
              icon: Icons.delete_outline,
              label: 'Remover da estante',
              iconColor: AppTheme.error,
              textColor: AppTheme.error,
              onTap: () => _confirmDelete(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Remover livro'),
        content: Text(
          'Deseja remover "${book.title}" da sua estante? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBook(book.id, userId);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppTheme.primary,
    this.textColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
