// ignore_for_file: use_build_context_synchronously

import 'dart:ffi';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hr_prob/auth_service.dart';
import 'package:hr_prob/signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  











  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email',enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Color.fromARGB(228, 42, 226, 5))
              )),
              
              
            ),
            SizedBox(height: 40),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password',enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Color.fromARGB(228, 42, 226, 5)),
              ),hoverColor:  Color.fromARGB(228, 42, 226, 5)),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = await _auth.signIn(
                  emailController.text,
                  passwordController.text,
                );
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please Enter a Vaild Username or Password")),
    );
                  
                }
              },style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(228, 42, 226, 5),
                
                
              ),
              child: Text('Login',style: TextStyle(color: Color.fromARGB(255, 10, 10, 10),
              fontWeight: FontWeight.bold),),
            ),
            TextButton(style: TextButton.styleFrom(backgroundColor:Color.fromARGB(228, 42, 226, 5)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text('Sign Up',style: TextStyle(color:  Color.fromARGB(255, 10, 10, 10),
              fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}


