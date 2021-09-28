import 'package:alignedstories/auth/authentication_logic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyButton(
              text: 'LOGIN WITH GOOGLE',
              fct: () {context.read<AuthenticationService>().signInWithGoogle();}
            ),
            MyButton(
              text: 'LOGIN',
              fct: () {Navigator.pushNamed(context,'/auth/signin');}
            ),
            MyButton(
              text: 'SIGN UP',
              fct: () {Navigator.pushNamed(context,'/auth/signup');}
            ),
          ]
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  SignInPage({ Key? key }) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextField(
              controller: emailController,
              hintText: 'email',
              icon: const Icon(Icons.email)
            ),
            MyTextField(
              controller: passwordController,
              hintText: 'password',
              icon: const Icon(Icons.password),
              password: true
            ),
            MyButton(
              text: 'LOGIN', 
              fct: () {
                context.read<AuthenticationService>().signIn(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim()
                );
                Navigator.pop(context);
              }
            )
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  SignUpPage({ Key? key }) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextField(
              controller: emailController,
              hintText: 'email',
              icon: const Icon(Icons.email)
            ),
            MyTextField(
              controller: passwordController,
              hintText: 'password',
              icon: const Icon(Icons.password),
              password: true
            ),
            MyButton(
              text: 'SIGNUP', 
              fct: () {
                context.read<AuthenticationService>().signUp(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim()
                );
                Navigator.pop(context);
              }
            )
          ],
        ),
      ),
    );
  }
}