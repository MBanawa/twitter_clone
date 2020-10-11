import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/comments.dart';
import 'package:twitter_clone/utils/variables.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uid;
  Stream userstream;
  String username;
  String profilepic;
  bool dataisthere = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserUid();
    getStream();
    getCurrentUserInfo();
  }

  getCurrentUserInfo() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc = await usercollection.doc(firebaseuser.uid).get();
    setState(() {
      username = userdoc['username'];
      profilepic = userdoc['profilepic'];
      dataisthere = true;
    });
  }

  getStream() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    setState(() {
      userstream = tweetcollection.where(firebaseuser.uid).snapshots();
    });
  }

  sharePost(String documentid, String tweet) async {
    Share.text('Flitter', tweet, 'text/plain');
    DocumentSnapshot document = await tweetcollection.doc(documentid).get();
    tweetcollection.doc(documentid).update({'shares': document['shares'] + 1});
  }

  getCurrentUserUid() {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    setState(() {
      uid = firebaseuser.uid;
    });
  }

  likePost(String documentid) async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot document = await tweetcollection.doc(documentid).get();

    if (document['likes'].contains(firebaseuser.uid)) {
      tweetcollection.doc(documentid).update({
        'likes': FieldValue.arrayRemove([firebaseuser.uid]),
      });
    } else {
      tweetcollection.doc(documentid).update({
        'likes': FieldValue.arrayUnion([firebaseuser.uid]),
      });
    }
  }

  // _signOut()  {
  //    FirebaseAuth.instance.signOut();
    
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dataisthere == true
          ? SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.lightBlue, Colors.teal])),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 6,
                      left: MediaQuery.of(context).size.width / 2 - 64,
                    ),
                    child: CircleAvatar(
                      radius: 64.0,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(profilepic),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 2.7,
                    ),
                    child: Column(
                      children: [
                        Text(
                          username,
                          style: myStyle(
                            30,
                            Colors.black,
                            FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Following',
                              style: myStyle(20, Colors.black, FontWeight.w600),
                            ),
                            Text(
                              'Followers',
                              style: myStyle(20, Colors.black, FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '12',
                              style: myStyle(20, Colors.black, FontWeight.w600),
                            ),
                            Text(
                              '20',
                              style: myStyle(20, Colors.black, FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              gradient: LinearGradient(colors: [
                                Colors.blue.shade700,
                                Colors.lightBlue
                              ]),
                            ),
                            child: Center(
                              child: Text('Edit Profile',
                                  style: myStyle(
                                      25, Colors.white, FontWeight.w600)),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          'User Tweets',
                          style: myStyle(25, Colors.black, FontWeight.w600),
                        ),
                        StreamBuilder(
                            stream: userstream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (BuildContext context, int index) {
                                  DocumentSnapshot tweetdoc =
                                      snapshot.data.documents[index];
                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                            tweetdoc['profilepic']),
                                      ),
                                      title: Text(
                                        tweetdoc['username'],
                                        style: myStyle(
                                            20, Colors.black, FontWeight.w500),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (tweetdoc['type'] == 1)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                tweetdoc['tweet'],
                                                style:
                                                    myStyle(20, Colors.black),
                                              ),
                                            ),
                                          if (tweetdoc['type'] == 2)
                                            Image(
                                              image: NetworkImage(
                                                  tweetdoc['image']),
                                            ),
                                          if (tweetdoc['type'] == 3)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tweetdoc['tweet'],
                                                    style: myStyle(
                                                        20, Colors.black),
                                                  ),
                                                  Image(
                                                    image: NetworkImage(
                                                        tweetdoc['image']),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          SizedBox(height: 10.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  InkWell(
                                                      onTap: () => Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CommentPage(
                                                                      tweetdoc[
                                                                          'id']))),
                                                      child:
                                                          Icon(Icons.comment)),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    tweetdoc['commentcount']
                                                        .toString(),
                                                    style: myStyle(18),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  InkWell(
                                                      onTap: () => likePost(
                                                          tweetdoc['id']),
                                                      child: tweetdoc['likes']
                                                              .contains(uid)
                                                          ? Icon(
                                                              Icons.favorite,
                                                              color: Colors.red,
                                                            )
                                                          : Icon(Icons
                                                              .favorite_border)),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    tweetdoc['likes']
                                                        .length
                                                        .toString(),
                                                    style: myStyle(18),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  InkWell(
                                                      onTap: () => sharePost(
                                                          tweetdoc['id'],
                                                          tweetdoc['tweet']),
                                                      child: Icon(Icons.share)),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    tweetdoc['shares']
                                                        .toString(),
                                                    style: myStyle(18),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            })
                      ],
                    ),
                  ),

                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
