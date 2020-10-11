import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_clone/utils/variables.dart';

class AddTweet extends StatefulWidget {
  @override
  _AddTweetState createState() => _AddTweetState();
}

class _AddTweetState extends State<AddTweet> {
  File imagepath;
  TextEditingController tweetController = TextEditingController();
  bool uploading = false;

  pickImage(ImageSource imgSource) async {
    final image = await ImagePicker().getImage(source: imgSource);
    setState(() {
      imagepath = File(image.path);
    });
    Navigator.pop(context);
  }

  optionsDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              onPressed: () => pickImage(ImageSource.gallery),
              child: Text(
                'Image from gallery',
                style: myStyle(20),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => pickImage(ImageSource.camera),
              child: Text(
                'Image from camera',
                style: myStyle(20),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: myStyle(20),
              ),
            ),
          ],
        );
      },
    );
  }

  uplodaImage(String id) async {
    StorageUploadTask storageUploadTask =
        tweetpictures.child(id).putFile(imagepath);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    String downloadurl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadurl;
  }

  postTweet() async {
    setState(() {
      uploading = true;
    });
    var fireBaseUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc = await usercollection.doc(fireBaseUser.uid).get();

    var alldocuments = await tweetcollection.get();
    int length = alldocuments.docs.length;
    // has 3 conditions
    // tweet only
    if (tweetController.text != '' && imagepath == null) {
      tweetcollection.doc('Tweet $length').set({
        'username': userdoc['username'],
        'profilepic': userdoc['profilepic'],
        'uid': fireBaseUser.uid,
        'id': 'Tweet $length',
        'tweet': tweetController.text,
        'likes': [],
        'commentcount': 0,
        'shares': 0,
        'type': 1,
      });
      Navigator.pop(context);
    }

    // image only
    if (tweetController.text == '' && imagepath != null) {
      String imageurl = await uplodaImage('Tweet $length');
      tweetcollection.doc('Tweet $length').set({
        'username': userdoc['username'],
        'profilepic': userdoc['profilepic'],
        'uid': fireBaseUser.uid,
        'id': 'Tweet $length',
        'image': imageurl,
        'likes': [],
        'commentcount': 0,
        'shares': 0,
        'type': 2,
      });
      Navigator.pop(context);
    }
    // tweet and image
    if (tweetController.text != '' && imagepath != null) {
      String imageurl = await uplodaImage('Tweet $length');
      tweetcollection.doc('Tweet $length').set({
        'username': userdoc['username'],
        'profilepic': userdoc['profilepic'],
        'uid': fireBaseUser.uid,
        'id': 'Tweet $length',
        'tweet': tweetController.text,
        'image': imageurl,
        'likes': [],
        'commentcount': 0,
        'shares': 0,
        'type': 3,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => postTweet(),
        child: Icon(Icons.send),
      ),
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            size: 32.0,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Add Tweet',
          style: myStyle(20),
        ),
        actions: [
          InkWell(
            onTap: () => optionsDialog(),
            child: Icon(
              Icons.photo,
              size: 30,
            ),
          ),
        ],
      ),
      body: uploading == false
          ? Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: tweetController,
                    maxLines: null,
                    style: myStyle(20),
                    decoration: InputDecoration(
                        labelText: 'What\'s happening now?',
                        labelStyle: myStyle(25),
                        border: InputBorder.none),
                  ),
                ),
                imagepath == null
                    ? Container()
                    : MediaQuery.of(context).viewInsets.bottom > 0
                        ? Container()
                        : Image(
                            width: 200,
                            height: 200,
                            image: FileImage(imagepath),
                          ),
              ],
            )
          : Center(
              child: Text(
                'Uploading.....',
                style: myStyle(25),
              ),
            ),
    );
  }
}
