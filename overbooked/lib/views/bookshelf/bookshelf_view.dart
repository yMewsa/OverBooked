import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bookshelf_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_book_sheet.dart';
import '../../widgets/shelf_section.dart';

/// The main bookshelf screen — the app's home tab.
/// Shows three shelves: Lendo agora, Quero ler, and Lidos e resenhados.
class BookshelfView extends StatelessWidget {
  const BookshelfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: Consumer<BookshelfProvider>(
        builder: (context, bookshelf, _) {
          if (bookshelf.isLoading) return _buildShimmerLoading();
          if (bookshelf.errorMessage != null) {
            return _buildErrorState(context, bookshelf);
          }
          return _buildBookshelf(context, bookshelf);
        },
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.auto_stories, color: AppTheme.accent, size: 24),
          const SizedBox(width: 8),
          Text(
            'Overbooked',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accent.withOpacity(0.15),
            child: const Icon(Icons.person, size: 18, color: AppTheme.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildBookshelf(BuildContext context, BookshelfProvider bookshelf) {
    final userId = context.read<AuthProvider>().user!.uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShelfSection(
            title: 'Lendo agora',
            books: bookshelf.readingNow,
            userId: userId,
          ),
          ShelfSection(
            title: 'Quero ler',
            books: bookshelf.wantToRead,
            userId: userId,
          ),
          ShelfSection(
            title: 'Lidos e resenhados',
            books: bookshelf.read,
            userId: userId,
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openSearch(context),
      backgroundColor: AppTheme.accent,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _openSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _BookSearchSheet(),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.divider,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (_, __) => _ShimmerShelf(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, BookshelfProvider bookshelf) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppTheme.secondaryText),
            const SizedBox(height: 16),
            Text(
              bookshelf.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final uid = context.read<AuthProvider>().user!.uid;
                context.read<BookshelfProvider>().init(uid);
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book Search Sheet ──────────────────────────────────────────────────────────

class _BookSearchSheet extends StatefulWidget {
  const _BookSearchSheet();

  @override
  State<_BookSearchSheet> createState() => _BookSearchSheetState();
}

class _BookSearchSheetState extends State<_BookSearchSheet> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    setState(() => _hasSearched = true);
    context.read<BookshelfProvider>().searchBooks(query);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user!.uid;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => Column(
        children: [
          // Handle + search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: const BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  decoration: InputDecoration(
                    hintText: 'Buscar por título ou autor...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.secondaryText),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppTheme.secondaryText),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<BookshelfProvider>()
                                  .clearSearch();
                              setState(() => _hasSearched = false);
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Results
          Expanded(
            child: Consumer<BookshelfProvider>(
              builder: (context, bookshelf, _) {
                if (bookshelf.isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!_hasSearched) {
                  return _EmptySearchPrompt();
                }

                if (bookshelf.errorMessage != null) {
                  return _SearchError(message: bookshelf.errorMessage!);
                }

                if (bookshelf.searchResults.isEmpty) {
                  return _NoResults(query: _searchController.text);
                }

                return GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: bookshelf.searchResults.length,
                  itemBuilder: (_, index) {
                    final book = bookshelf.searchResults[index];
                    return GestureDetector(
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppTheme.background,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        builder: (_) =>
                            AddBookSheet(book: book, userId: userId),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: book.coverUrl != null
                                  ? Image.network(
                                      book.coverUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          _SearchBookPlaceholder(),
                                    )
                                  : _SearchBookPlaceholder(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary),
                          ),
                          Text(
                            book.authorsDisplay,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.secondaryText),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBookPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppTheme.accent.withOpacity(0.1),
        child: const Center(
          child: Icon(Icons.menu_book, size: 28, color: AppTheme.accent),
        ),
      );
}

class _EmptySearchPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Busque livros por título ou autor',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.secondaryText),
            ),
          ],
        ),
      );
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Nenhum resultado para "$query"',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.secondaryText),
            ),
          ],
        ),
      );
}

class _SearchError extends StatelessWidget {
  final String message;
  const _SearchError({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.secondaryText),
            ),
          ],
        ),
      );
}

// ── Shimmer placeholder ────────────────────────────────────────────────────────

class _ShimmerShelf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 18, width: 140, color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10)),
          Container(height: 8, color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12)),
          SizedBox(
            height: 180,
            child: Row(
              children: List.generate(
                3,
                (_) => Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
