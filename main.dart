// ignore_for_file: use_key_in_widget_constructors, avoid_print, prefer_const_declarations, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hr_prob/app_secrets.dart';
import 'package:hr_prob/firebase_options.dart';
import 'package:hr_prob/home_screen.dart';
import 'package:hr_prob/login_screen.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _clearFirestoreData();
  runApp(MyApp());
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;
String uid = user?.uid ?? 'unknown';
Future<void> _clearFirestoreData() async {
  final collection = _firestore.collection(uid);
  final snapshots = await collection.get();
  for (var doc in snapshots.docs) {
    await doc.reference.delete();
  }
  print("deleted");
}
















class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      title: 'Recruitment App',
      home:LoginScreen(),
    );
  }
}

