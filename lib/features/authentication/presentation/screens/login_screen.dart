import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


 // Clase privada _ significa privada 
class _LoginScreenState extends State<LoginScreen> {
  //Creamos llave global para identificar y controlar el formulario
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Visilibilidad de pass
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


//Funcion de validacion 
void _onLoginButtonPressed(){
  if(!_formKey.currentState!.validate()){
    return;
  }

  //Enviar a bloc
  BlocProvider.of<LoginBloc>(context).add(
    LoginButtonPressed(
    email: _emailController.text,
     password: _passwordController.text, 
     ),
  );
}


  @override
  Widget build(BuildContext context) {
 
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is  LoginSuccess) {
     
       Navigator.pushReplacementNamed(context, '/home');
        }
        if (state is LoginFailure) {         
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

    child: Scaffold(
        body: Stack(
          children: [
           
            Container(height: MediaQuery.of(context).size.height * 0.5, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/logo6.jpg'), fit: BoxFit.cover))),
            SafeArea(child: Container(padding: const EdgeInsets.only(top: 40.0), alignment: Alignment.topCenter, child: const Column(children: [Icon(Icons.home, color: Colors.white, size: 80), SizedBox(height: 10), Text('ALQUILADORA ROMERO', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))]))),
            
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
                    
              
                    child: Form(
                      key: _formKey, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          const Text('Iniciar Sesion', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                          const SizedBox(height: 30),
                          
                          
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(hintText: 'Correo', prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)), filled: true, fillColor: Colors.grey[100]),
                           
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa tu correo';
                              }
                           
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Por favor, ingresa un correo válido';
                              }
                              return null; 
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          
                          TextFormField(
                            controller: _passwordController,
                           
                            obscureText: !_isPasswordVisible, 
                            decoration: InputDecoration(
                              hintText: 'Contraseña', 
                              prefixIcon: const Icon(Icons.lock_outline),
                             
                              suffixIcon: IconButton(
                                icon: Icon(
                                 
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)), 
                              filled: true, 
                              fillColor: Colors.grey[100]
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('¿Olvidaste tu Contraseña?', style: TextStyle(color: Color(0xFF2196F3))))),
                          const SizedBox(height: 20),
                          BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              if (state is LoginLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return ElevatedButton(
                              
                                onPressed: _onLoginButtonPressed,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 236, 203, 130), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                                child: const Text('Iniciar Sesion', style: TextStyle(fontSize: 18, color: Colors.black87)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(height: 50, color: const  Color.fromARGB(255, 236, 203, 130), child: const Center(child: Text('Tambien puedes iniciar session en la web', style: TextStyle(color: Colors.black87)))),
      ),
    );
  }
}



