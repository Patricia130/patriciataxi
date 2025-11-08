import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const googleMapsAPIKey = "GOOGLE_MAPS_KEY";
const loggedInPref = "loggedIn";
const authPref = "id";
// firebase
final Future<FirebaseApp> initialization = Firebase.initializeApp();

FirebaseFirestore firebaseFiretore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseMessaging fcm = FirebaseMessaging.instance;

const profilePref = "PROFILE_PREF";
const requestIdPref = "REQUEST_ID";
