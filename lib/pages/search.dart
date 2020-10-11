import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/pages/viewuser.dart';
import 'package:twitter_clone/utils/variables.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<QuerySnapshot> searchuseresult;
  searchuser(String s) {
    var users = usercollection
        .where('username', isGreaterThanOrEqualTo: s)
        .get();

    setState(() {
      searchuseresult = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffECE5DA),
        appBar: AppBar(
          title: TextFormField(
            decoration: InputDecoration(
                filled: true,
                hintText: "Search for users..",
                hintStyle: myStyle(18)),
            onFieldSubmitted: searchuser,
          ),
        ),
        body: searchuseresult == null
            ? Center(
                child: Text(
                  "Search for users....",
                  style: myStyle(30),
                ),
              )
            : FutureBuilder(
                future: searchuseresult,
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot user = snapshot.data.documents[index];
                      return Card(
                        elevation: 8.0,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(user['profilepic']),
                          ),
                          title: Text(
                            user['username'],
                            style: myStyle(25),
                          ),
                          trailing: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewUser(user['uid']))),
                            child: Container(
                              width: 90,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.lightBlue),
                              child: Center(
                                child: Text("View", style: myStyle(20)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ));
  }
}