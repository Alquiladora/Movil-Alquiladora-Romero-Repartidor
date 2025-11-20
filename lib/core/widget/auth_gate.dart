
import 'package:flutter/material.dart';
import '../../core/services/token_service.dart'; 
import '../../features/dashboard/presentation/home_screen/home_screen.dart'; 
import './layaout_appbar.dart'; 


class AuthGate extends StatefulWidget {
    const AuthGate({super.key});

    @override
    State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
    final TokenService _tokenService = TokenService(); 

    @override
    void initState() {
        super.initState();
        _checkAuthStatus();
    }

    void _checkAuthStatus() async {
        if (!mounted) return;
        
        final token = await _tokenService.getToken();

        final navigator = Navigator.of(context);
        
        if (token != null && token.isNotEmpty) {
            navigator.pushReplacementNamed('/home');
        } else {
            navigator.pushReplacementNamed('/login');
        }
    }

    @override
    Widget build(BuildContext context) {
    
        return const Scaffold(
          backgroundColor: Color(0xFFF5F7FA),
            body: Center(
                child: CircularProgressIndicator(), 
            ),
        );
    }
}