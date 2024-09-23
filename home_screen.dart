import 'package:flutter/material.dart';
import 'package:hr_prob/auth_service.dart';
import 'package:hr_prob/leaderboard.dart';
import 'package:hr_prob/login_screen.dart';
import 'package:hr_prob/upload_resume_screen.dart';
class HomeScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),

      body: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadResumeScreen()),
                );
              },style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(228, 42, 226, 5),
                
                
              ),
              child: Text('Upload Resume',style: TextStyle(color: Color.fromARGB(255, 10, 10, 10),
              fontWeight: FontWeight.bold),),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LeaderboardScreen()),
                );
              },style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(228, 42, 226, 5),
                
                
              ),
              child: Text('View Leaderboard',style: TextStyle(color: Color.fromARGB(255, 10, 10, 10),
              fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}
