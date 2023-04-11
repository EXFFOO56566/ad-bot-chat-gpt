import 'dart:async';

import 'package:adbot/helper/admob_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../helper/notification_helper.dart';
import '../model/chat_model/chat_model.dart';
import '../model/user_model/user_model.dart';
import '../services/api_services.dart';
import '../utils/strings.dart';

class ChatController extends GetxController {
  Timer? timer;

  @override
  void onInit() {
    NotificationHelper.initInfo();

    speech = stt.SpeechToText();
    LocalStorage.isLoggedIn() ? _getUserData() : _setGesutUser();

    count.value = LocalStorage.getTextCount();

    if(LocalStorage.getAdMobStatus()){
      _adShowWidget();
    }

    super.onInit();
  }

  _adShowWidget() {
    RxBool visible = LocalStorage.showAdPermissioned().obs;
    if (visible.value) {
      timer = Timer.periodic(const Duration(seconds: 60),
          (Timer t) => AdMobHelper.getInterstitialAdLoad()
      );
    }
  }

  final chatController = TextEditingController();
  final scrollController = ScrollController();

  // final RxList messages = <ChatMessage>[].obs;
  Rx<List<ChatMessage>> messages = Rx<List<ChatMessage>>([]);
  List<String> shareMessages = ['--THIS IS CONVERSATION with ADBOT--\n\n'];
  RxInt itemCount = 0.obs;
  RxInt voiceSelectedIndex = 0.obs;
  RxBool isLoading = false.obs;

  late UserModel userModel;

  final List<String> moreList = [
    Strings.regenerateResponse.tr,
    Strings.clearConversation.tr,
    Strings.share.tr
  ];

  void proccessChat() async {
    speechStopMethod();

    addTextCount();

    messages.value.add(
      ChatMessage(
        text: chatController.text,
        chatMessageType: ChatMessageType.user,
      ),
    );
    shareMessages.add("${chatController.text} - Myself\n");
    itemCount.value = messages.value.length;
    isLoading.value = true;

    var input = chatController.text;
    textInput.value = chatController.text;
    chatController.clear();
    update();

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    update();

    debugPrint("---------------S------------------");
    debugPrint("SEND TEXT");
    debugPrint(input);
    debugPrint(input);
    debugPrint("---------------E------------------");

    ApiServices.generateResponse(input).then((value) {
      isLoading.value = false;
      debugPrint("---------------S------------------");
      debugPrint("RECEIVED");
      debugPrint(value);
      debugPrint(value);
      debugPrint("---------------E------------------");

      messages.value.add(
        ChatMessage(
          text: value.replaceFirst("\n", " ").replaceFirst("\n", " "),
          chatMessageType: ChatMessageType.bot,
        ),
      );
      shareMessages.add(
          "${value.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By ADBOT\n");
      Future.delayed(const Duration(milliseconds: 50))
          .then((_) => scrollDown());
      itemCount.value = messages.value.length;
    });

    chatController.clear();

    update();
  }

  RxString textInput = ''.obs;

  void proccessChat2() async {
    speechStopMethod();

    addTextCount();
    messages.value.add(
      ChatMessage(
        text: Strings.regeneratingResponse.tr,
        chatMessageType: ChatMessageType.user,
      ),
    );
    shareMessages.add('${Strings.regeneratingResponse.tr} -Myself\n');
    itemCount.value = messages.value.length;
    isLoading.value = true;

    update();

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    update();

    ApiServices.generateResponse(textInput.value).then((value) {
      isLoading.value = false;
      messages.value.add(
        ChatMessage(
          text: value.replaceFirst("\n", " ").replaceFirst("\n", " "),
          chatMessageType: ChatMessageType.bot,
        ),
      );
      shareMessages.add(
          "${value.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By ADBOT\n");
      Future.delayed(const Duration(milliseconds: 50))
          .then((_) => scrollDown());
      itemCount.value = messages.value.length;
    });

    chatController.clear();
    update();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  RxString userInput = "".obs;
  RxString result = "".obs;

  late stt.SpeechToText speech;

  RxBool isListening = false.obs;

  var languageList = LocalStorage.getLanguage();

  void listen(BuildContext context) async {
    speechStopMethod();

    chatController.text = '';
    result.value = '';
    userInput.value = '';
    if (isListening.value == false) {
      bool available = await speech.initialize(
        onStatus: (val) => debugPrint('*** onStatus: $val'),
        onError: (val) => debugPrint('### onError: $val'),
      );
      if (available) {
        isListening.value = true;
        speech.listen(
            localeId: languageList[0],
            onResult: (val) {
              chatController.text = val.recognizedWords.toString();
              userInput.value = val.recognizedWords.toString();
            });
      }
    } else {
      isListening.value = false;
      speech.stop();
      update();
    }
  }

  final FlutterTts flutterTts = FlutterTts();

  final _isSpeechLoading = false.obs;

  bool get isSpeechLoading => _isSpeechLoading.value;

  final _isSpeech = false.obs;

  bool get isSpeech => _isSpeech.value;

  speechMethod(String text, String language) async {
    _isSpeechLoading.value = true;
    _isSpeech.value = true;
    update();

    await flutterTts.setLanguage(language);
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(text);

    Future.delayed(
        const Duration(seconds: 2), () => _isSpeechLoading.value = false);
    update();
  }

  speechStopMethod() async {
    _isSpeech.value = false;
    await flutterTts.stop();
    update();
  }

  clearConversation() {
    speechStopMethod();
    messages.value.clear();
    shareMessages.clear();
    shareMessages.add('--THIS IS CONVERSATION with ADBOT--\n\n');
    textInput.value = '';
    itemCount.value = 0;
    speechStopMethod();
    update();
  }

  void _getUserData() async {
    final FirebaseAuth userAuth =
        FirebaseAuth.instance; // firebase instance/object

    // Get the user form the firebase
    User? user = userAuth.currentUser;

    UserModel userData = UserModel(
        name: user!.displayName ?? "",
        uniqueId: user.uid,
        email: user.email!,
        phoneNumber: user.phoneNumber ?? "",
        isActive: true,
        imageUrl: user.photoURL ?? "");

    userModel = userData;

    messages.value.add(
      ChatMessage(
        text: '${Strings.hello.tr} ${userData.name}',
        chatMessageType: ChatMessageType.bot,
      ),
    );
    shareMessages.add("${Strings.hello.tr} ${userData.name} -By ADBOT\n");

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    itemCount.value = messages.value.length;
    update();
  }

  void _setGesutUser() async {
    // Get the user form the firebase

    UserModel userData = UserModel(
        name: "Guest",
        uniqueId: '',
        email: '',
        phoneNumber: '',
        isActive: false,
        imageUrl: '');

    userModel = userData;

    messages.value.add(
      ChatMessage(
        text: Strings.helloGuest.tr,
        chatMessageType: ChatMessageType.bot,
      ),
    );
    shareMessages.add("${Strings.helloGuest.tr} -By ADBOT\n\n");

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    itemCount.value = messages.value.length;
    update();
  }

  void shareChat(BuildContext context) {
    debugPrint(shareMessages.toString());
    Share.share("${shareMessages.toString()}\n\n --CONVERSATION END--",
        subject: "I'm sharing Conversation with ADBOT");
  }

  final FirebaseAuth _auth = FirebaseAuth.instance; // firebase instance/object
  User get user => _auth.currentUser!;
  RxInt count = 0.obs;

  //count.value = LocalStorage.getTextCount();
  addTextCount() async {
    debugPrint("-------${count.value.toString()}--------");
    count.value++;
    LocalStorage.saveTextCount(count: count.value);

    await FirebaseFirestore.instance
        .collection('adbotUsers')
        .doc(LocalStorage.getId())
        .update({"textCount": count.value});
  }
}
