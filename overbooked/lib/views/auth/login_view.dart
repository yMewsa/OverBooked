import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'signup_view.dart';

/// Email/password login screen.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.signIn(_emailController.text, _passwordController.text);

    if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 28),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.auto_stories,
            size: 36,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Overbooked',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sua estante virtual de leitura',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryText,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'E-mail',
        prefixIcon: Icon(Icons.mail_outline, color: AppTheme.secondaryText),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe seu e-mail';
        }
        if (!value.contains('@')) return 'E-mail inválido';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.secondaryText),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.secondaryText,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe sua senha';
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _submit,
            child: auth.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Entrar'),
          ),
        );
      },
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem conta? ',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppTheme.secondaryText),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignupView()),
          ),
          style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
          child: const Text(
            'Criar conta',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
