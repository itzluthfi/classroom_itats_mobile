import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppFirebaseService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission(provisional: true);

    await firebaseMessaging
        .getToken(vapidKey: dotenv.get("VAPID_KEY"))
        .then((t) {
      if (t != null) {
        storage.write(key: "client-token", value: t);
        print('mobile token: $t');
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }
}
