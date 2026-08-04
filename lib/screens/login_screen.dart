import 'admin_dashboard.dart';
import '../services/user_service.dart';imimport 'home_screen.dart';import 'register_screen.dart';port 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidgefinal userService = UserService();

final admin = await userService.isAdmin(
  emailController.text,
);


if(admin){

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const AdminDashboard(),
    ),
  );

}
else{

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
  );

}t {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const HomeScreen(),
  ),
);
class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  void login() async {
    try {
      await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful"),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Shop Login"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),

          ],
        ),
      ),
    );
  }
}
const SizedBox(height: 10),

TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  },
  child: const Text("Create Account"),
),
