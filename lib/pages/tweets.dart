import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/comments.dart';
import 'package:twitter_clone/utils/variables.dart';
import 'package:twitter_clone/addtweet.dart';

class TweetsPage extends StatefulWidget {
  @override
  _TweetsPageState createState() => _TweetsPageState();
}

class _TweetsPageState extends State<TweetsPage> {
  String uid;
  String username;
  @override
  void initState() {
    super.initState();
    getCurrentUserUid();
  }

  
  

  sharePost(String documentid, String tweet) async {
    Share.text('Flitter', tweet, 'text/plain');
    DocumentSnapshot document = await tweetcollection.doc(documentid).get();
    tweetcollection.doc(documentid).update({'shares': document['shares'] + 1});
  }

  getCurrentUserUid() async{
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTweet()),
          );
        },
        child: Icon(
          Icons.add,
          size: 32,
        ),
      ),
      appBar: AppBar(
        actions: [
          Icon(
            Icons.star,
            size: 32,
          ),
        ],
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Flitter',
              style: myStyle(
                20,
                Colors.white,
                FontWeight.w700,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            Image(
              width: 35,
              height: 35,
              image: AssetImage('images/flutter.png'),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: tweetcollection.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot tweetdoc = snapshot.data.documents[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(tweetdoc['profilepic']),
                    ),
                    title: Text(
                      tweetdoc['username'],
                      style: myStyle(20, Colors.black, FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tweetdoc['type'] == 1)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tweetdoc['tweet'],
                              style: myStyle(20, Colors.black),
                            ),
                          ),
                        if (tweetdoc['type'] == 2)
                          Image(
                            image: NetworkImage(tweetdoc['image']),
                          ),
                        if (tweetdoc['type'] == 3)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tweetdoc['tweet'],
                                  style: myStyle(20, Colors.black),
                                ),
                                Image(
                                  image: NetworkImage(tweetdoc['image']),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CommentPage(
                                                tweetdoc['id']))),
                                    child: Icon(Icons.comment)),
                                SizedBox(width: 10.0),
                                Text(
                                  tweetdoc['commentcount'].toString(),
                                  style: myStyle(18),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                    onTap: () => likePost(tweetdoc['id']),
                                    child: tweetdoc['likes'].contains(uid)
                                        ? Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          )
                                        : Icon(Icons.favorite_border)),
                                SizedBox(width: 10.0),
                                Text(
                                  tweetdoc['likes'].length.toString(),
                                  style: myStyle(18),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                    onTap: () => sharePost(
                                        tweetdoc['id'], tweetdoc['tweet']),
                                    child: Icon(Icons.share)),
                                SizedBox(width: 10.0),
                                Text(
                                  tweetdoc['shares'].toString(),
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
          }),
    );
  }
}
