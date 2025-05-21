import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/user/profile_page.dart';
import 'package:flutter_application_1/screens/user/team_page.dart';
import 'package:flutter_application_1/screens/user/vote_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VotePage(),     
    TeamPage(),    
    ProfilePage(), 
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${user?.displayName ?? 'User'}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('auth');
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Vote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}