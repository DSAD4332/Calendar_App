import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/login_sc.dart';

class AccountButton extends StatefulWidget {
  final GoogleSignInAccount user;

  const AccountButton({Key? key, required this.user}) : super(key: key);

  @override
  _AccountButtonState createState() => _AccountButtonState();
}

class _AccountButtonState extends State<AccountButton> {
  final AuthService _authService = AuthService();
  late GoogleSignInAccount currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user; // Инициализируем начального пользователя
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: currentUser.photoUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(currentUser.photoUrl!),
            )
          : const Icon(Icons.account_circle, color: Colors.white),
      onPressed: () async {
        try {
          GoogleSignInAccount? newUser = await _authService.switchAccount();
          if (newUser != null) {
            setState(() {
              currentUser = newUser; // Обновляем состояние текущего пользователя
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Switched to: ${newUser.displayName}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error switching account')),
          );
        }
      },
    );
  }
}

