import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helper/local_storage.dart';

class MainController  {

  static getCredentials() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('credentials')
        .doc('manage-api-key')
        .get();

    LocalStorage.saveChatGptApiKey(key: userDoc.get('chat-gpt-api-key'));
    LocalStorage.saveStripeClientId(key: userDoc.get('strive-client-id'));
    LocalStorage.savePaypalClientId(key: userDoc.get('paypal-client-id'));
    LocalStorage.savePaypalSecret(key: userDoc.get('paypal-secret'));

    debugPrint("""
        Get ChatGpt Api Key ↙️
        ${LocalStorage.getChatGptApiKey()},
        Get Paypal ClientId ↙️
        ${LocalStorage.getPaypalClientId()},
        Get Stripe ClientId ↙️
        ${LocalStorage.getStripeClientId()},
        Get Paypal Secret ↙️
        ${LocalStorage.getPaypalSecret()},
        """);
  }
}
