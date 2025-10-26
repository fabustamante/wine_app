import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wine_app/services/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controladores
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(authProvider.notifier);
    
    final success = await auth.signIn(
      _usernameController.text,
      _passwordController.text,
    );
    
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Usuario o contraseña incorrectos'))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Center(child: Text('Bienvenido ${_usernameController.text}!'))),
    );
    context.go('/wines');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.state == AuthState.authenticating;

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Wine App'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _LoginCard(
              usernameController: _usernameController,
              passwordController: _passwordController,
              onSubmit: () => _submit(),
              isLoading: isLoading,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
    required this.isLoading,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Login", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _UsernameField(controller: usernameController),
            const SizedBox(height: 12),
            _PasswordField(controller: passwordController),
            const SizedBox(height: 12),
            _LoginButton(onPressed: onSubmit, loading: isLoading),
          ],
        ),
      ),
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: 'Username',
        suffixIcon: Icon(Icons.person, size: 24, color: Colors.deepPurple[600]),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller});
  final TextEditingController controller;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: 'Password',
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      obscureText: _obscure,
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed, this.loading = false});
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed, 
        child: loading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Inicio de sesión'),
      ),
    );
  }
}
