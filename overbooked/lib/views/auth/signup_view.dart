import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

/// New account registration screen.
class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.signUp(_emailController.text, _passwordController.text);

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
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 36),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 28),
                _buildSignUpButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
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
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.person_add_outlined,
            size: 32,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Criar conta',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Comece sua jornada de leitura',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppTheme.secondaryText),
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
        if (value == null || value.trim().isEmpty) return 'Informe seu e-mail';
        if (!value.contains('@')) return 'E-mail inválido';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppTheme.secondaryText),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.secondaryText,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe uma senha';
        if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: 'Confirmar senha',
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppTheme.secondaryText),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.secondaryText,
          ),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (value) {
        if (value != _passwordController.text) return 'As senhas não conferem';
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
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
                : const Text('Cadastrar'),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem uma conta? ',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppTheme.secondaryText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
          child: const Text(
            'Fazer login',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
