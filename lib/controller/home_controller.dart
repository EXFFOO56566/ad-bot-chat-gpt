
import 'package:adbot/widgets/api/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/local_storage.dart';
import '../helper/notification_helper.dart';
import '../routes/routes.dart';
import '../utils/constants.dart';
import '../utils/language/english.dart';
import '../utils/strings.dart';
import 'login_controller.dart';

class HomeController extends GetxController {
  var selectedLanguage = "".obs;
  final loginController = Get.put(LoginController());


  @override
  void onInit() {
    NotificationHelper.initInfo();
    selectedLanguage.value = languageStateName;
    // getCredentials();
    checkPremium();
    super.onInit();
  }

  onChangeLanguage(var language, int index) {

    selectedLanguage.value = language;
    if (index == 0) {
      LocalStorage.saveLanguage(
        langSmall: 'en',
        langCap: 'US',
        languageName: English.english,
      );
      languageStateName = English.english;
    } else if (index == 1) {
      LocalStorage.saveLanguage(
        langSmall: 'sp',
        langCap: 'SP',
        languageName: English.spanish,
      );
      languageStateName = English.spanish;
    } else if (index == 2) {
      LocalStorage.saveLanguage(
        langSmall: 'ar',
        langCap: 'AR',
        languageName: English.arabic,
      );
      languageStateName = English.arabic;
    }
    else if (index == 3) {
      LocalStorage.saveLanguage(
        langSmall: 'bn',
        langCap: 'BN',
        languageName: English.bengali,
      );
      languageStateName = English.bengali;
    }
    else if (index == 4) {
      LocalStorage.saveLanguage(
        langSmall: 'hn',
        langCap: 'HN',
        languageName: English.hindi,
      );
      languageStateName = English.hindi;
    }
  }

  final List<String> moreList = [
    Strings.english,
    Strings.spanish,
    Strings.arabic,
    Strings.bengali,
    Strings.hindi,
  ];

  final List<String> menuList = [
    Strings.supportAndFeedback,
    Strings.deleteAccount
  ];

  logout() {
    _removeStorage();
    Get.offAllNamed(Routes.loginScreen);
  }

  deleteAccount() async{

    final user = FirebaseAuth.instance.currentUser!;
    debugPrint("_________________________________");
    debugPrint(user.toString());
    debugPrint("_________________________________");

    await FirebaseFirestore.instance
        .collection('adbotUsers')
        .doc(user.uid)
        .delete();

    debugPrint("_______________DELETE USER DATA__________________");
    await user.delete();
    debugPrint("_______________DELETE USER AUTH__________________");

    _removeStorage();

    debugPrint("_______________LOCAL STORAGE CLEAR__________________");

    ToastMessage.success("Delete Successfully!");
    Get.offAllNamed(Routes.splashScreen);
  }

  _removeStorage() {
    LocalStorage.logout();
  }

  checkPremium() async{
    final uid = LocalStorage.getId();
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('adbotUsers')
        .doc(uid)
        .get();

    if (userDoc.get('isPremium')) {
      LocalStorage.saveTextCount(count: userDoc.get('textCount'));
      LocalStorage.showAdYes(isShowAdYes: !userDoc.get('isPremium'));
    } else {
      LocalStorage.saveTextCount(count: userDoc.get('textCount'));
    }

    update();
  }
}
