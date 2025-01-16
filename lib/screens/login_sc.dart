import 'package:calendar_app/screens/home_sc.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;

  AuthService()
      : _googleSignIn = GoogleSignIn(
          clientId:
              '915166643849-llj6t4ad6rbqal393t3mhehht99ouc8p.apps.googleusercontent.com',
          scopes: [
            'email',
            'profile',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          ],
        );

  // Проверка статуса входа
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Получение текущего пользователя
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  // Вход с использованием Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  // Выход из Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('User signed out');
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }

  // Смена аккаунта
  Future<GoogleSignInAccount?> switchAccount() async {
    await signOut();
    return signInWithGoogle();
  }
}

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Проверка состояния входа при загрузке экрана
    _checkSignInStatus(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Sign-In"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sign in using your Google account"),
            const SizedBox(height: 20),
            // Кнопка входа через Google
            FutureBuilder<bool>(
              future: _authService.isSignedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data == false) {
                  return GestureDetector(
                    onTap: () async {
                      try {
                        final account = await _authService.signInWithGoogle();
                        if (account != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(user: account)),
                          );
                          print('User signed in: ${account.displayName}');
                        } else {
                          print('Sign-In canceled or failed.');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign-in failed: $e')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data == true) {
                  return ElevatedButton(
                    onPressed: () async {
                      await _authService.switchAccount();
                      print('Switched account.');
                    },
                    child: const Text("Switch Account"),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Метод для проверки статуса входа
  void _checkSignInStatus(BuildContext context) async {
    final bool isSignedIn = await _authService.isSignedIn();
    if (isSignedIn) {
      final currentUser =
          _authService.currentUser; // Получаем текущего пользователя
      if (currentUser != null) {
        // Если пользователь уже вошел, переходим на главный экран
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: currentUser),
          ),
        );
      }
    }
  }
}
