import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

// =========================================================================
// ECRÃ DE LOGIN (LOGIN SCREEN)
// =========================================================================
// Fornece a interface de entrada no jogo com validações de inputs locais
// e autenticação reativa ligada ao AuthProvider.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // =========================================================================
  // 1. CHAVES GLOBAIS E CONTROLADORES DE INPUTS
  // =========================================================================
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================================================
  // 2. SUBMISSÃO E VALIDAÇÃO DE CREDENCIAIS
  // =========================================================================
  // SUBMISSÃO DE FORMULÁRIO (Defesa):
  // Valida o estado atual do Form (campos preenchidos), remove o foco dos campos
  // para fechar o teclado e executa o login assíncrono via AuthProvider.
  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      FocusScope.of(context).unfocus();

      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bem-vindo ao Joker!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais inválidas. Tenta novamente.'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  // =========================================================================
  // 3. ESTRUTURA PRINCIPAL DA UI (MÉTODO BUILD)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 60),
                
                GlowingInputField(
                  controller: _usernameController,
                  labelText: 'Nome de Utilizador',
                  icon: Icons.person,
                  validator: (value) => 
                      value!.isEmpty ? 'Por favor, insere o teu nome de utilizador.' : null,
                ),
                const SizedBox(height: 24),
                
                GlowingInputField(
                  controller: _passwordController,
                  labelText: 'Palavra-passe',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) => 
                      value!.isEmpty ? 'Por favor, insere a tua palavra-passe.' : null,
                ),
                const SizedBox(height: 40),
                
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                    : _buildLoginButton(context),
                
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF2E2B0), // Dourado Champagne
                  ),
                  child: const Text(
                    'Não tens conta? Criar Conta',
                    style: TextStyle(letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 4. COMPONENTES VISUAIS DA INTERFACE (LOGO E BOTÕES)
  // =========================================================================

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF001133), // Azul imperial
                  border: const Border.symmetric(
                    horizontal: BorderSide(color: Color(0xFFD4AF37), width: 2.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Container(
                width: 180,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF001133),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'JOKER',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF2E2B0), // Dourado Champagne
                    letterSpacing: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'O DESAFIO FINAL',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Color(0xFFF2E2B0),
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF2E2B0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _submitLogin,
        child: const Text(
          'ENTRAR',
          style: TextStyle(
            color: Color(0xFF001133),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// =========================================================================
  // 5. DETALHES DE ESTILO PREMIUM (BACKGROUND E INPUT FIELDS)
  // =========================================================================

// Fundo Premium para os ecrãs de autenticação com formas geométricas em rotação.
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001133),
      body: Stack(
        children: [
          // Top Left Triangle
          Positioned(
            top: -50,
            left: -50,
            child: Opacity(
              opacity: 0.05,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 200,
                  height: 200,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ),
          ),
          // Bottom Right Triangle
          Positioned(
            bottom: -50,
            right: -50,
            child: Opacity(
              opacity: 0.05,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 200,
                  height: 200,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

// Componente de input com feedback de brilho neon (glow) dourado reativo ao foco.
class GlowingInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const GlowingInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
  });

  @override
  State<GlowingInputField> createState() => _GlowingInputFieldState();
}

class _GlowingInputFieldState extends State<GlowingInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF00081A), // Fundo azul marinho muito escuro
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFF2E2B0), // Dourado Champagne
            width: 2.0,
          ),
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5), // Brilho suave
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: Color(0xFFF2E2B0)),
        cursorColor: const Color(0xFFF2E2B0),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: _isFocused ? const Color(0xFFF2E2B0) : const Color(0xFFF2E2B0).withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(widget.icon, color: const Color(0xFFD4AF37)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
