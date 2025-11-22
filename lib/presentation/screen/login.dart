import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wine_app/presentation/viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _isLoginMode = true; // true = login, false = register
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailPassword() async {
    setState(() => _loading = true);
    try {
      bool ok;
      if (_isLoginMode) {
        ok = await ref.read(authProvider.notifier).signInWithEmailAndPassword(
              _emailController.text,
              _passwordController.text,
            );
      } else {
        ok = await ref.read(authProvider.notifier).signUpWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
              username: _usernameController.text,
              age: int.tryParse(_ageController.text),
            );
      }

      if (!mounted) return;

      if (!ok) {
        final authStatus = ref.read(authProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(authStatus.errorMessage ?? 'Error de autenticación'),
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(_isLoginMode ? '¡Bienvenido!' : '¡Cuenta creada exitosamente!'),
          ),
        ),
      );
      context.go('/wines');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final ok = await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return;

      if (!ok) {
        final authStatus = ref.read(authProvider);
        if (authStatus.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text(authStatus.errorMessage!)),
            ),
          );
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('¡Bienvenido!'))),
      );
      context.go('/wines');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Wine App'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _LoginCard(
              emailController: _emailController,
              passwordController: _passwordController,
              usernameController: _usernameController,
              ageController: _ageController,
              onSubmit: _submitEmailPassword,
              onGoogleSignIn: _signInWithGoogle,
              isLoading: _loading,
              isLoginMode: _isLoginMode,
              onToggleMode: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.ageController,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.isLoading,
    required this.isLoginMode,
    required this.onToggleMode,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final TextEditingController ageController;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleSignIn;
  final bool isLoading;
  final bool isLoginMode;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLoginMode ? "Iniciar Sesión" : "Crear Cuenta",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _EmailField(controller: emailController),
            const SizedBox(height: 12),
            _PasswordField(controller: passwordController),
            if (!isLoginMode) ...[
              const SizedBox(height: 12),
              _UsernameField(controller: usernameController),
              const SizedBox(height: 12),
              _AgeField(controller: ageController),
            ],
            const SizedBox(height: 12),
            _LoginButton(
              onPressed: onSubmit,
              loading: isLoading,
              label: isLoginMode ? 'Iniciar Sesión' : 'Registrarse',
            ),
            const SizedBox(height: 12),
            const _Divider(),
            const SizedBox(height: 12),
            _GoogleSignInButton(
              onPressed: onGoogleSignIn,
              loading: isLoading,
            ),
            const SizedBox(height: 12),
            _ToggleModeButton(
              isLoginMode: isLoginMode,
              onPressed: onToggleMode,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: 'Correo electrónico',
        suffixIcon: Icon(Icons.email, size: 24, color: Colors.deepPurple[600]),
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
        labelText: 'Nombre de usuario',
        suffixIcon: Icon(Icons.person, size: 24, color: Colors.deepPurple[600]),
      ),
    );
  }
}

class _AgeField extends StatelessWidget {
  const _AgeField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: 'Edad (opcional)',
        suffixIcon: Icon(Icons.cake, size: 24, color: Colors.deepPurple[600]),
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
        labelText: 'Contraseña',
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
  const _LoginButton({
    required this.onPressed,
    required this.label,
    this.loading = false,
  });
  final VoidCallback onPressed;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.onPressed,
    this.loading = false,
  });
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.login, size: 20),
        label: const Text('Continuar con Google'),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('O', style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(child: Divider(color: Colors.grey[400])),
      ],
    );
  }
}

class _ToggleModeButton extends StatelessWidget {
  const _ToggleModeButton({
    required this.isLoginMode,
    required this.onPressed,
  });
  final bool isLoginMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        isLoginMode
            ? '¿No tienes cuenta? Regístrate'
            : '¿Ya tienes cuenta? Inicia sesión',
      ),
    );
  }
}
