import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';

/// The "Placar de Leitura" (Reading Scoreboard) screen.
/// Displays real-time reading statistics from Firestore.
class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Placar de Leitura'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, _) {
          if (statsProvider.isLoading) {
            return _buildShimmerLoading();
          }
          return _buildContent(context, statsProvider);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, StatsProvider statsProvider) {
    final stats = statsProvider.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, stats.booksRead),
          const SizedBox(height: 24),
          // Stats cards row
          Row(
            children: [
              StatCard(
                label: 'Livros\nlidos',
                value: stats.booksRead,
                icon: Icons.auto_stories,
              ),
              const SizedBox(width: 12),
              StatCard(
                label: 'Páginas\nlidas',
                value: stats.pagesRead,
                icon: Icons.format_list_numbered,
              ),
              const SizedBox(width: 12),
              StatCard(
                label: 'Páginas\neste mês',
                value: stats.pagesReadThisMonth,
                icon: Icons.calendar_month_outlined,
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildMotivationCard(context, stats.booksRead),
          const SizedBox(height: 20),
          _buildInfoNote(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int booksRead) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC68B3A), Color(0xFF8B5E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registro do Acervo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$booksRead volumes',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'lidos ao total',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.local_library_outlined,
            size: 52,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard(BuildContext context, int booksRead) {
    final (emoji, title, subtitle) = booksRead == 0
        ? (
            '🌱',
            'Comece sua jornada!',
            'Adicione um livro à sua estante e marque-o como lido para ver suas estatísticas.',
          )
        : booksRead < 5
            ? (
                '🚀',
                'Ótimo começo!',
                'Você está construindo um hábito de leitura incrível. Continue assim!',
              )
            : booksRead < 20
                ? (
                    '📚',
                    'Leitor dedicado!',
                    'Impressionante! Sua estante está crescendo. Que venham mais livros!',
                  )
                : (
                    '🏆',
                    'Leitor voraz!',
                    'Você é uma inspiração! Seu amor pelos livros é extraordinário.',
                  );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: AppTheme.secondaryText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'As estatísticas são atualizadas automaticamente quando você marca um livro como lido.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.divider,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    height: 110,
                    margin: EdgeInsets.only(left: i > 0 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
