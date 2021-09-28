import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback fct;
  const MyButton({ 
    Key? key,
    required this.text,
    required this.fct
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: 0.7*size.width,
        child: OutlinedButton(
          onPressed: fct,
          child: Text(
            text,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0)
            )
          )
        )
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool password;
  final Icon icon;

  const MyTextField({ 
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.password = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: TextField(
        obscureText: password,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          icon: icon,
          border: InputBorder.none,
        ),
      ),
    );
  }
}