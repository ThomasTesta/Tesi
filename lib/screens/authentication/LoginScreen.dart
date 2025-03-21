import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seawatch/services/AuthServiceGeneral/AuthService.dart';
import 'package:seawatch/services/ManagementTheme/ThemeProvider.dart'; // Importiamo il servizio di login

/*
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Funzione per gestire il login
    void _login() async {
      final email = emailController.text;
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inserisci email e password'),
          ),
        );
        return;
      }

      try {
        await AuthService().login(email, password); // Chiamata al servizio di login
        Navigator.pushReplacementNamed(context, '/main'); // Naviga alla schermata principale
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Immagine in alto
                Image.asset(
                  'assets/images/FinSpot_pos.png',
                  height: 120,
                ),
                const SizedBox(height: 40),

                // Campo Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 16),

                // Campo Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 40),

                // Pulsante "Accedi"
                ElevatedButton.icon(
                  onPressed: _login, // Chiamiamo il metodo di login
                  icon: const Icon(Icons.login, size: 24),
                  label: const Text(
                    'Accedi',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 20),

                // Pulsante "Registrati"
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registrazione');
                  },
                  child: const Text(
                    'Non hai un account? Registrati',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seawatch/services/AuthServiceGeneral/AuthService.dart';
import 'package:seawatch/services/ManagementTheme/ThemeProvider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Funzione per gestire il login (supporta offline)
    void _login() async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inserisci email e password')),
        );
        return;
      }

      try {
        final authService = AuthService();
        await authService.attemptLogin(email, password);
        
        // Se il login è riuscito (online o offline), naviga alla home
        Navigator.pushReplacementNamed(context, '/main');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore di accesso: ${e.toString()}')),
        );
      }
    }
return Scaffold(
  backgroundColor: Colors.white,
  body: SafeArea(
    child: Center( // Questo centra il contenuto nella schermata
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Evita che la colonna occupi tutto lo spazio
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/FinSpot_pos.png',
              height: 120,
            ),
            const SizedBox(height: 40),

            // Campo Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),

            // Campo Password
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 40),

            // Pulsante "Accedi"
            ElevatedButton.icon(
              onPressed: _login,
              icon: const Icon(Icons.login, size: 24),
              label: const Text(
                'Accedi',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 20),

            // Pulsante "Registrati"
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registrazione');
              },
              child: const Text(
                'Non hai un account? Registrati',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}