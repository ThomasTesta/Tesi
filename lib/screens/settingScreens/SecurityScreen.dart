import 'package:flutter/material.dart';
import 'package:seawatch/services/AuthServiceGeneral/AuthServices.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userController = TextEditingController();

  final AuthServices authServices = AuthServices();
  String _message = "";
  bool isLoading = false;

  void _changePassword() async {
    final user = _userController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        _message = "❌ Le nuove password non corrispondono.";
      });
      return;
    }

    setState(() {
      _message = "⏳ Attendi...";
      isLoading = true;
    });

    final result = await authServices.changePassword(user, oldPassword, newPassword);

    setState(() {
      _message = result["message"] ?? "❌ Errore sconosciuto.";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambio Password", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInputField(
                controller: _userController,
                label: "Utente",
                icon: Icons.person,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                controller: _oldPasswordController,
                label: "Vecchia Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                controller: _newPasswordController,
                label: "Nuova Password",
                icon: Icons.lock_reset,
                isPassword: true,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                controller: _confirmPasswordController,
                label: "Conferma Nuova Password",
                icon: Icons.check_circle_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              _buildButton(
                text: "Cambia Password",
                color: theme.colorScheme.primary,
                icon: Icons.security,
                onPressed: _changePassword,
              ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _message.contains("❌") ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _message.contains("❌") ? Icons.error_outline : Icons.check_circle_outline,
                        color: _message.contains("❌") ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _message,
                        style: TextStyle(
                          color: _message.contains("❌") ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon, size: 20),
      label: Text(text, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
