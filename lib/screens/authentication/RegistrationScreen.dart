import 'package:flutter/material.dart';
import 'package:seawatch/services/AuthServiceGeneral/RegistrationService.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController cognomeController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    // Funzione per gestire la registrazione
    void _register() async {
      final nome = nomeController.text;
      final cognome = cognomeController.text;
      final email = emailController.text;
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      if (nome.isEmpty || cognome.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compila tutti i campi!'),
          ),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le password non corrispondono!'),
          ),
        );
        return;
      }

      try {
        await RegistrationService().register(nome, cognome, email, password); // Chiamata al metodo di registrazione
        Navigator.pushReplacementNamed(context, '/login'); // Reindirizza alla pagina di login
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Campo Nome
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Cognome
              TextField(
                controller: cognomeController,
                decoration: const InputDecoration(
                  labelText: 'Cognome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Conferma Password
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Conferma Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),

              // Pulsante "Crea nuovo account"
              ElevatedButton(
                onPressed: _register, // Chiamiamo il metodo di registrazione
                child: const Text('Crea nuovo account'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              // Link per tornare alla schermata di login
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Torna alla schermata di login
                },
                child: const Text('Hai già un account? Accedi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
