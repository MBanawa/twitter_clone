import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'package:twitter_clone/utils/variables.dart';

class CommentPage extends StatefulWidget {
  final String documentId;

  CommentPage(this.documentId);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  var commentcontroller = TextEditingController();

  addComment() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc = await usercollection.doc(firebaseuser.uid).get();
    tweetcollection.doc(widget.documentId).collection('comments').doc().set({
      'comment': commentcontroller.text,
      'username': userdoc['username'],
      'uid': userdoc['uid'],
      'profilepic': userdoc['profilepic'],
      'time': DateTime.now(),
    });
    DocumentSnapshot commentcount = await tweetcollection.doc(widget.documentId).get();

    tweetcollection.doc(widget.documentId).update({
      'commentcount': commentcount['commentcount'] + 1
    });
    commentcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text(
      //     'Comments',
      //     style: myStyle(20),
      //   ),
      // ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: tweetcollection
                      .doc(widget.documentId)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot commentDoc =
                            snapshot.data.documents[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage:
                                NetworkImage(commentDoc['profilepic']),
                          ),
                          title: Row(
                            children: [
                              Text(
                                commentDoc['username'],
                                style:
                                    myStyle(20, Colors.black, FontWeight.w500),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(
                                commentDoc['comment'],
                                style: myStyle(
                                  20,
                                  Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            tAgo.format(commentDoc['time'].toDate()).toString(),
                            style: myStyle(15),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: TextFormField(
                  controller: commentcontroller,
                  decoration: InputDecoration(
                    hintText: 'Add a Comment..',
                    hintStyle: myStyle(18),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                trailing: OutlineButton(
                  onPressed: () => addComment(),
                  borderSide: BorderSide.none,
                  child: Text(
                    'Publish',
                    style: myStyle(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
