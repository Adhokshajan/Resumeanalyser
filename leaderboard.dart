import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreen();
}

class _LeaderboardScreen extends State<LeaderboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
    

  
























  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String uid = user?.uid ?? 'unknown';
 
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var resumes = snapshot.data!.docs;
          resumes.sort((a, b) => (b['rank']).compareTo(a['rank']));
          return ListView.builder(
            itemCount: resumes.length,
            itemBuilder: (context, index) {
              var resume = resumes[index];
              return ListTile(
                title: Text(resume['name']),
                subtitle: Text('Rank: ${resume['rank']}'),
              );
            },
          );
        },
      ),
    );
  }
}