import '../helper/notification_helper.dart';

import '../widgets/api/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/local_storage.dart';
import '../routes/routes.dart';

class PlanController extends GetxController {
  RxString prise = '9'.obs;

  // join meeting
  final paypalController = TextEditingController();
  final stripeController = TextEditingController();
  final nameOnCardController = TextEditingController();
  final cardNumberController = TextEditingController();
  final dateController = TextEditingController();
  final cvvOrCvcController = TextEditingController();
  final mmOrYyyyController = TextEditingController();


  updateUserPlan() async {
    var collection = FirebaseFirestore.instance.collection('adbotUsers');
    collection.doc(LocalStorage.getId()).update({'isPremium': true});
    ToastMessage.success('Your Plan Updated to Premium');
    LocalStorage.showAdYes(isShowAdYes: false);
    Get.offNamedUntil(Routes.homeScreen, (route) => false);
  }


  @override
  void onInit() {
    NotificationHelper.initInfo();

    // TODO: implement onInit
    super.onInit();
  }


  @override
  void dispose() {
    paypalController.dispose();
    stripeController.dispose();
    nameOnCardController.dispose();
    cardNumberController.dispose();
    dateController.dispose();
    cvvOrCvcController.dispose();
    mmOrYyyyController.dispose();

    super.dispose();
  }

  navigateToDashboardScreen() {
    Get.toNamed(Routes.homeScreen);
  }


  RxString selectedMethod = ''.obs;

  final List<String> paymentMethod = [
    'Paypal',
    'Stripe'
  ];

}