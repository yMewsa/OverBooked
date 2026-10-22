import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';

/// Profile and account management screen.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = context.watch<StatsProvider>().stats;
    final email = auth.user?.email ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildAvatar(email),
            const SizedBox(height: 16),
            Text(
              email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Leitor Ativo',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Quick stats summary
            _buildStatsSummary(context, stats),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 16),
            // Account actions
            _buildMenuItem(
              context,
              icon: Icons.notifications_outlined,
              label: 'Notificações',
              onTap: () => _showComingSoon(context),
            ),
            _buildMenuItem(
              context,
              icon: Icons.backup_outlined,
              label: 'Exportar dados',
              onTap: () => _showComingSoon(context),
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip_outlined,
              label: 'Privacidade',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildSignOutButton(context),
            const SizedBox(height: 32),
            Text(
              'Overbooked v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Feito com ❤️ para leitores',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String email) {
    final initial =
        email.isNotEmpty ? email[0].toUpperCase() : '?';
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.accent, AppTheme.shelfWood],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBadge(
            value: stats.booksRead.toString(),
            label: 'Livros',
          ),
          Container(width: 1, height: 40, color: AppTheme.divider),
          _StatBadge(
            value: stats.pagesRead.toString(),
            label: 'Páginas',
          ),
          Container(width: 1, height: 40, color: AppTheme.divider),
          _StatBadge(
            value: stats.pagesReadThisMonth.toString(),
            label: 'Este mês',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppTheme.secondaryText, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.secondaryText,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Sair da conta'),
        onPressed: () => _confirmSignOut(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: const BorderSide(color: AppTheme.error),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Sair da conta'),
        content: const Text(
          'Deseja sair da sua conta? Seus dados ficam salvos na nuvem.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve! 🚀')),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;

  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }
}
