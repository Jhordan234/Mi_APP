import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Agregado para Firebase
import 'register_screen.dart'; // Importación necesaria para la navegación
import 'loading_screen.dart'; // Importación necesaria para la pantalla de carga

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;

  // --- AGREGADO: Controladores para capturar texto ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.05)).animate(
          CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    // --- AGREGADO: Dispose de controladores ---
    _emailController.dispose();
    _passwordController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN DE LOGIN ACTUALIZADA ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Campos vacíos")),
      );
      return;
    }

    try {
      // 1. Intentar el login en Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. SI TODO SALE BIEN: Mandar a la pantalla de carga
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoadingScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 3. SI HAY ERROR: Mostrar mensaje detallado
      String errorMsg = "ACCESO DENEGADO";
      if (e.code == 'user-not-found') errorMsg = "Usuario no registrado";
      if (e.code == 'wrong-password') errorMsg = "Contraseña incorrecta";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 🌌 Fondo con resplandor radial
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // 🤖 EL ROBOTITO
                  SlideTransition(
                    position: _floatingAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/robotito.png',
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                        // Badge de Estado "Auth Mode"
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: _buildBadge(theme, isDark),
                        ),
                      ],
                    ),
                  ),

                  // 🏷️ TÍTULO DEL SISTEMA
                  const SizedBox(height: 32),
                  Text(
                    'INICIAR SESION',
                    style: GoogleFonts.orbitron(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                          blurRadius: 15.0,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 📝 FORMULARIO DE ACCESO
                  _buildSynthTextField(
                    label: 'CORREO',
                    icon: Icons.person_search_outlined,
                    hint: 'Ingresa tu Correo',
                    theme: theme,
                    controller: _emailController, // Conectado
                  ),
                  const SizedBox(height: 20),
                  _buildSynthTextField(
                    label: 'CONTRASEÑA',
                    icon: Icons.vpn_key_outlined,
                    hint: '••••••••',
                    isPassword: true,
                    theme: theme,
                    controller: _passwordController, // Conectado
                  ),

                  const SizedBox(height: 50),

                  // ⚡ BOTÓN DE ACCESO PRINCIPAL
                  _buildSubmitButton(theme, isDark),

                  const SizedBox(height: 30),

                  // 📝 SECCIÓN: BOTÓN PARA IR A REGISTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿NO TIENES UNA CUENTA? ',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'REGISTRARSE',
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
                  Text(
                    'NIVEL DE SEGURIDAD: ALPHA_7',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el Badge del Robotito
  Widget _buildBadge(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        'AUTONOMO',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.black : Colors.white,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Widget para los Inputs Neón
  Widget _buildSynthTextField({
    required String label,
    required IconData icon,
    required String hint,
    required ThemeData theme,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary.withOpacity(0.8),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
            filled: true,
            fillColor: theme.colorScheme.surface.withOpacity(0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget para el Botón Brillante
  Widget _buildSubmitButton(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF00BCCF)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin, // Conectado a la función de login
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'INICIAR ACCESO',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.black : Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.login,
              color: isDark ? Colors.black : Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}