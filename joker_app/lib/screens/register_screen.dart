import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'login_screen.dart'; // Import to reuse AuthBackground & GlowingInputField

// =========================================================================
// ECRÃ DE REGISTO DE UTILIZADORES (REGISTER SCREEN)
// =========================================================================
// Permite criar um novo jogador, validando inputs localmente e suportando
// a captura/seleção de uma fotografia para upload de perfil.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // =========================================================================
  // 1. CONTROLADORES, CHAVES E SELEÇÃO DE MEDIA
  // =========================================================================
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================================================
  // 2. CAPTURA E PROCESSAMENTO DA FOTO DE PERFIL
  // =========================================================================
  
  // SELEÇÃO DE FOTO (Defesa):
  // Exibe um painel inferior (BottomSheet) para escolher entre Câmara ou Galeria.
  // A Câmara é ocultada em Desktop (macOS/Windows/Linux) pois necessita
  // de plugins/permissões complexas de vídeo.
  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF001133),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFFD4AF37)),
                  title: const Text('Galeria / Ficheiros', style: TextStyle(color: Color(0xFFF2E2B0))),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickFromGallery();
                  },
                ),
              ),
              if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.camera_alt, color: Color(0xFFD4AF37)),
                    title: const Text('Câmara', style: TextStyle(color: Color(0xFFF2E2B0))),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickFromCamera();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    // Pequeno delay para o macOS processar o evento de clique
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // No Desktop, o FilePicker abre a janela nativa do Finder/Explorer
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _imageFile = File(result.files.single.path!);
          });
          debugPrint("Imagem selecionada com sucesso (FilePicker): ${_imageFile!.path}");
        } else {
          debugPrint("Utilizador cancelou a seleção.");
        }
      } else {
        // Em Mobile, usamos o ImagePicker
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
          debugPrint("Imagem selecionada com sucesso (ImagePicker): ${_imageFile!.path}");
        }
      }
    } catch (e) {
      debugPrint("Erro ao abrir galeria: $e");
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        debugPrint("Foto tirada com sucesso: ${_imageFile!.path}");
      }
    } catch (e) {
      debugPrint("Erro ao abrir câmara: $e");
    }
  }

  // =========================================================================
  // 3. SUBMISSÃO DE REGISTO DE UTILIZADORES
  // =========================================================================
  
  // REGISTO ASSÍNCRONO (Defesa):
  // Valida regras do formulário (email válido, senha >= 6 caracteres, etc.),
  // fecha o teclado virtual e submete o formulário Multipart para a API.
  Future<void> _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      FocusScope.of(context).unfocus();

      final success = await _apiService.register(
        _nameController.text.trim(),
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        imageFile: _imageFile,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Podes fazer login.'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar conta. O utilizador ou e-mail já podem existir.'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal header for Register
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFF2E2B0)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'CRIAR CONTA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37), // Dourado metalizado
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // balance the back button
                  ],
                ),
                const SizedBox(height: 32),

                // Imagem de Perfil
                Center(
                  child: GestureDetector(
                    onTap: () => _showPickerOptions(context),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00081A),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imageFile == null
                              ? const Icon(Icons.person, size: 50, color: Color(0xFFD4AF37))
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4AF37),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Color(0xFF001133)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                GlowingInputField(
                  controller: _nameController,
                  labelText: 'Nome Completo',
                  icon: Icons.badge,
                  validator: (value) => 
                      value!.isEmpty ? 'Por favor, insere o teu nome.' : null,
                ),
                const SizedBox(height: 20),

                GlowingInputField(
                  controller: _usernameController,
                  labelText: 'Nome de Utilizador',
                  icon: Icons.person_outline,
                  validator: (value) => 
                      value!.isEmpty ? 'Por favor, escolhe um nome de utilizador.' : null,
                ),
                const SizedBox(height: 20),

                GlowingInputField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'E-mail',
                  icon: Icons.email,
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor, insere o teu e-mail.';
                    if (!value.contains('@')) return 'Insere um e-mail válido.';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                GlowingInputField(
                  controller: _passwordController,
                  labelText: 'Palavra-passe',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor, insere uma palavra-passe.';
                    if (value.length < 6) return 'A palavra-passe deve ter pelo menos 6 caracteres.';
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                    : _buildRegisterButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 4. COMPONENTES VISUAIS DA INTERFACE (BOTÕES E ENTRADAS)
  // =========================================================================

  Widget _buildRegisterButton() {
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
        onPressed: _submitRegister,
        child: const Text(
          'REGISTAR',
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
