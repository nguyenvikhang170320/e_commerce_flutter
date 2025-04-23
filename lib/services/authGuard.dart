import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return auth.isLoggedIn ? child : LoginPage();
  }
}
