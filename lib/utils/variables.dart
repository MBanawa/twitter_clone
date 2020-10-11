import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

myStyle(double size, [Color color, FontWeight fw]) {
  return GoogleFonts.montserrat(
    fontSize: size,
    fontWeight: fw,
    color: color,
  );
}

CollectionReference usercollection =
    FirebaseFirestore.instance.collection('users');

CollectionReference tweetcollection =
    FirebaseFirestore.instance.collection('tweets');

StorageReference tweetpictures =
    FirebaseStorage.instance.ref().child('tweetpictures');

var defaultImage =
    'https://www.vpsmalaysia.com.my/wp-content/uploads/backup/2016/09/profile-picture.png';
