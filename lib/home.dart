import 'package:flutter/material.dart';


import 'package:twitter_clone/pages/tweets.dart';
import 'package:twitter_clone/pages/search.dart';
import 'package:twitter_clone/pages/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //  Future<void> _signOut() async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  int page = 0;
  List pageOptions = [
    TweetsPage(),
    SearchPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.black,
        currentIndex: page,
        onTap: (index){
          setState(() {
            page = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 32,
              ),
              label: 'Tweets'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 32,
              ),
              label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 32,
              ),
              label: 'Profile'),
        ],
      ),
      body: pageOptions[page],
    );
  }
}
