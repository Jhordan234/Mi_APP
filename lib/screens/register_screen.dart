import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;

  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _dniController      = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name     = _nameController.text.trim();
    final dni      = _dniController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || dni.isEmpty || email.isEmpty || password.isEmpty) {
      _showMsg("Completa todos los campos neurales.");
      return;
    }

    if (!email.contains('@')) {
      _showMsg("El formato de correo no es válido.");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': name,
        'dni': dni,
        'correo': email,
        'fecha_registro': FieldValue.serverTimestamp(),
        'rol': 'operador',
      });

      _showMsg("Acceso concedido. Perfil Neural Creado.");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showMsg("ERROR DE SISTEMA: ${e.message}");
    }
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Imagen de fondo ────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo2.png',
              fit: BoxFit.cover,
            ),
          ),
          // ── Overlay oscuro ─────────────────────────────────────────────
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          // ── Contenido ──────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Robotito sin fondo
                    SlideTransition(
                      position: _floatingAnimation,
                      child: Image.asset(
                        'assets/images/robotito_registro.png',
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'NUEVO OPERADOR',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'REGISTRO DE CREDENCIALES NEURALES',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    _buildRegisterInput(
                      label: 'NOMBRE COMPLETO',
                      icon: Icons.badge_outlined,
                      hint: 'Ej. Juan Pérez',
                      theme: theme,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    _buildRegisterInput(
                      label: 'DNI / IDENTIFICACIÓN',
                      icon: Icons.fingerprint,
                      hint: 'Número de documento',
                      theme: theme,
                      isNumeric: true,
                      controller: _dniController,
                    ),
                    const SizedBox(height: 20),
                    _buildRegisterInput(
                      label: 'CORREO ELECTRÓNICO',
                      icon: Icons.alternate_email,
                      hint: 'usuario@synth.com',
                      theme: theme,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),
                    _buildRegisterInput(
                      label: 'CONTRASEÑA DE ACCESO',
                      icon: Icons.lock_open_outlined,
                      hint: '••••••••',
                      isPassword: true,
                      theme: theme,
                      controller: _passwordController,
                    ),

                    const SizedBox(height: 40),

                    _buildActionButton(theme, isDark),

                    const SizedBox(height: 30),

                    // ── Igual al botón de login pero al revés ─────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿YA TIENES UNA CUENTA? ',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'INICIAR SESIÓN',
                            style: GoogleFonts.orbitron(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterInput({
    required String label,
    required IconData icon,
    required String hint,
    required ThemeData theme,
    required TextEditingController controller,
    bool isPassword = false,
    bool isNumeric  = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary.withOpacity(0.7),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric
              ? [FilteringTextInputFormatter.digitsOnly,
                 LengthLimitingTextInputFormatter(8)]
              : [],
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 18),
            filled: true,
            fillColor: theme.colorScheme.surface.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF00BCCF)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'CREAR CUENTA',
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.black : Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}