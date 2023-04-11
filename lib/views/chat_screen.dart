import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/chat_controller.dart';
import '../helper/local_storage.dart';
import '../utils/custom_color.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/api/custom_loading_api.dart';
import '../widgets/api/toast_message.dart';
import '../widgets/appbar/appbar_widget.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/inputs_widgets/send_input_field.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({Key? key}) : super(key: key);

  final controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await controller.speechStopMethod();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(
          context: context,
          onBackClick: () {
            controller.speechStopMethod();
            Get.back();
          },
          appTitle: Strings.chatWithAdBot.tr,
          onPressed: () {
            _showDialog(context);
          },
        ),
        body: _mainBody(context),
      ),
    );
  }

  _mainBody(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Expanded(
            flex: 5,
            child: _buildList(),
          ),
          Expanded(
            flex: 0,
            child: Obx(() => Visibility(
                visible: controller.isLoading.value,
                child: const CustomLoadingAPI())),
          ),
          Expanded(flex: 0, child: _submitButton(context)),
          SizedBox(height: Dimensions.heightSize)
        ],
      ),
    );
  }

  _submitButton(BuildContext context) {
    var value = 5 - controller.count.value;
    var messagesLeft = value <= 0 ? Strings.outOffLimit.tr : value;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          Visibility(
            visible: LocalStorage.showAdPermissioned(),
            child: Column(
              children: [
                Visibility(
                  visible: controller.count.value == 0,
                  child:  Text(
                    '${Strings.youCanSend.tr} 5 ${Strings.messagesToTheBot.tr} ',
                    style: const TextStyle(color: CustomColor.primaryColor),
                  ),
                ),
                Visibility(
                  visible: controller.count.value >0,
                  child: Text(
                            "${messagesLeft.toString().tr} ${Strings.messagesLeft.tr}",
                            style: const TextStyle(color: CustomColor.primaryColor),
                          ),
                ),
              ],
            ),
          )
          ,
          SendInputField(
            icon: Animator<double>(
              duration: const Duration(milliseconds: 1000),
              cycles: 0,
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: 15.0, end: 25.0),
              builder: (context, animatorState, child) => Obx(
                () => Icon(
                  Icons.mic_none_sharp,
                  size: animatorState.value,
                  color: controller.isListening.value
                      ? CustomColor.primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
            ),
            hintText: Strings.typeYour.tr,
            onTap: () {
              if (!LocalStorage.showAdPermissioned()) {
                if (controller.chatController.text.isNotEmpty) {
                  controller.proccessChat();
                  Future.delayed(const Duration(milliseconds: 50))
                      .then((_) => controller.scrollDown());
                } else {
                  ToastMessage.error(Strings.writeSomethingg.tr);
                }
              } else {
                if (controller.count.value <= 5) {
                  debugPrint(controller.count.value.toString());
                  if (controller.chatController.text.isNotEmpty) {
                    controller.proccessChat();
                    Future.delayed(const Duration(milliseconds: 50))
                        .then((_) => controller.scrollDown());
                  } else {
                    ToastMessage.error(Strings.writeSomethingg.tr);
                  }
                } else {
                  debugPrint(controller.count.value.toString());
                  ToastMessage.error('Chat Limit is over. Buy subscription.');
                }
              }
            },
            voiceTab: () {
              controller.listen(context);
            },
            controller: controller.chatController,
          ),
        ],
      ),
    );
  }

  _buildList() {
    var languageList = LocalStorage.getLanguage();
    return Obx(() => ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.itemCount.value,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return ChatMessageWidget(
                onStop: () {
                  controller.speechStopMethod();
                },
                onSpeech: () {
                  controller.speechMethod(controller.messages.value[index].text,
                      '${languageList[0]}-${languageList[1]}');
                  controller.voiceSelectedIndex.value = index;
                },
                text: controller.messages.value[index].text,
                chatMessageType:
                    controller.messages.value[index].chatMessageType,
                index: index);
          },
        ));
  }

  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize * 3,
                vertical: Dimensions.heightSize),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                  controller.moreList.length,
                  (index) => Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.widthSize * 1,
                            vertical: Dimensions.heightSize * 0.5),
                        child: TextButton(
                            onPressed: () {
                              if (LocalStorage.showAdPermissioned()) {
                                // FacebookAdHelper.initAd();
                              }

                              if (index == 0) {
                                if (controller.textInput.value.isNotEmpty) {
                                  controller.proccessChat2();
                                }
                              } else if (index == 1) {
                                controller.clearConversation();
                              } else if (index == 2) {
                                if (controller.shareMessages.isEmpty) {
                                  Get.snackbar(
                                      'OH No!!', 'No Conversation yet');
                                  Get.back();
                                } else {
                                  controller.shareChat(context);
                                }
                              }

                              Get.back();
                            },
                            child: Text(
                              controller.moreList[index],
                              style: const TextStyle(
                                  color: CustomColor.blackColor),
                            )),
                      )),
            ),
          );
        });
  }
}
