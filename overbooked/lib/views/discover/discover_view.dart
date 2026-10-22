import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bookshelf_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_book_sheet.dart';

/// Book discovery screen — search Google Books and add them to the shelf.
class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
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

  void _clearSearch() {
    _searchController.clear();
    context.read<BookshelfProvider>().clearSearch();
    setState(() => _hasSearched = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Descoberta'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: Consumer<BookshelfProvider>(
        builder: (context, bookshelf, _) {
          if (bookshelf.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_hasSearched) {
            return _buildPromptState();
          }

          if (bookshelf.errorMessage != null) {
            return _buildErrorState(bookshelf.errorMessage!);
          }

          if (bookshelf.searchResults.isEmpty) {
            return _buildEmptyResults();
          }

          return _buildResults(context, bookshelf);
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: _search,
      decoration: InputDecoration(
        hintText: 'Buscar edições raras, autores, ISBNs...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryText),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.secondaryText),
                onPressed: _clearSearch,
              )
            : null,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildResults(BuildContext context, BookshelfProvider bookshelf) {
    final userId = context.read<AuthProvider>().user!.uid;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => AddBookSheet(book: book, userId: userId),
          ),
          child: _BookResultCard(book: book),
        );
      },
    );
  }

  Widget _buildPromptState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Explore o universo dos livros',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Busque por título, autor ou ISBN para encontrar seu próximo livro.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado encontrado',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente outro termo de busca.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppTheme.secondaryText),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _search(_searchController.text),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book Result Card ───────────────────────────────────────────────────────────

class _BookResultCard extends StatelessWidget {
  final dynamic book;

  const _BookResultCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverUrl != null
                    ? Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              // Tap hint overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppTheme.primary.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(8)),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
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
            color: AppTheme.primary,
          ),
        ),
        Text(
          book.authorsDisplay,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.menu_book, size: 28, color: AppTheme.accent),
      ),
    );
  }
}
