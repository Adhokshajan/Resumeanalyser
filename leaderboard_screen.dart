import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///class LeaderboardScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('leaderboard').snapshots(),
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
///}///
