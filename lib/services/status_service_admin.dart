
import 'package:flutter/material.dart';

import '../helper/local_storage.dart';

class StatusService{

  static init() {
    debugPrint('--------StatusService activate-------------');
     LocalStorage.saveChatStatus(chatStatusBool: true);
     LocalStorage.saveImageStatus(imageStatusBool: true);
     LocalStorage.saveSubscriptionStatus(subscriptionStatusBool: true);
     LocalStorage.saveAdMobStatus(adMobStatusBool: true);

     LocalStorage.saveStripeStatus(stripeStatusBool: true);
     LocalStorage.savePaypalStatus(paypalStatusBool: false);
  }
}