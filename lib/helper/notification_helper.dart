import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../model/notification_model/notification_model.dart';
import 'local_storage.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message ${message.messageId}');
  NotificationModel data = NotificationModel(
      title: message.notification!.title!,
      body: message.notification!.body!
  );

  debugPrint(data.toJson().toString());

  LocalStorage.saveAnouncment(notificationData: data);

  debugPrint('-----------Handling a background message ${message.messageId}----------------');
  debugPrint('-----------Handling a background message ${message.toString()}----------------');
  debugPrint('-----------Handling a background message $data}----------------');
  debugPrint('-----------Handling a background message ${message.notification!.title}----------------');
  debugPrint('-----------Handling a background message ${message.notification!.body}----------------');
}


class NotificationHelper{

  static requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('-----------Permission granted: ${settings.authorizationStatus}');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint(
          '-------------------User granted provisional permission: ${settings.authorizationStatus}');
    } else {
      debugPrint(
          '-------------User declined or has not accepted permission: ${settings.authorizationStatus}');
    }
  }

  static initialization()async{
    await FirebaseMessaging.instance
        .getInitialMessage();
  }

   // init info
  static initInfo( ) async{
    debugPrint('------------------Info initialize');
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const IOSInitializationSettings();
    // ignore: unused_local_variable
    var initializationSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iOSInitialize
    );


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // firebase operation starts here
      debugPrint('.....................onMessage.................');
      debugPrint(
          'onMessage: ${message.notification?.title}/${message.notification?.body}');

      NotificationModel data = NotificationModel(
          title: message.notification!.title!,
          body: message.notification!.body!
      );

       Get.snackbar(data.title, data.body, duration: const Duration(seconds: 3));

      debugPrint(data.toJson().toString());

      // _saveData(data);
      LocalStorage.saveAnouncment(notificationData: data);

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      // for android
      AndroidNotificationDetails androidNotificationDetailsSpecifics =
      AndroidNotificationDetails(
        'testChannel',
        'testChannel',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );
      // for ios
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidNotificationDetailsSpecifics,
          iOS: const IOSNotificationDetails()
      );
      // show the notification

      RemoteNotification? notification = message.notification;


      await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification!.title,
          notification.body,
          platformChannelSpecifics
      );
    });
  }

  static getBackgroundNotification(){
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}