import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseConfig {
  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBqE-AAM4TFcWg37s_gLSlcxdqm8NaFtW0',
    authDomain: 'diary-app-d8606.firebaseapp.com',
    // ✅ Kết nối chính xác tới Realtime Database URL của bạn
    databaseURL: 'https://diary-app-d8606-default-rtdb.asia-southeast1.firebasedatabase.app/',
    projectId: 'diary-app-d8606',
    storageBucket: 'diary-app-d8606.firebasestorage.app',
    messagingSenderId: '108669530022',
    appId: '1:108669530022:web:041dabe0b8e91adac36967',
    measurementId: 'G-SQFWF93G4F',
  );

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseDatabase get realtimeDb => FirebaseDatabase.instance;
}
