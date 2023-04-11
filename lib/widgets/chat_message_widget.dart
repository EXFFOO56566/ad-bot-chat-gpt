import '../utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/chat_controller.dart';
import '../helper/local_storage.dart';
import '../model/chat_model/chat_model.dart';
import '../utils/assets.dart';
import '../utils/custom_color.dart';

class ChatMessageWidget extends StatelessWidget {
  final controller = Get.put(ChatController());

  ChatMessageWidget(
      {super.key,
      required this.text,
      required this.onSpeech,
      required this.onStop,
      required this.index,
      required this.chatMessageType});

  final String text;
  final int index;
  final ChatMessageType chatMessageType;
  final VoidCallback onSpeech, onStop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: chatMessageType == ChatMessageType.bot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _robotIcon(),
          _chatBody(context),
          _userIcon(),
        ],
      ),
    );
  }

  _chatBody(BuildContext context) {
    return Expanded(
      flex: text.length < 20 ? 0 : 1,
      child: GestureDetector(
        onTap: onStop,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: chatMessageType == ChatMessageType.bot
                  ? Get.isDarkMode
                    ? CustomColor.primaryColor.withOpacity(0.2)
                    : CustomColor.primaryColor
                  : Get.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                bottomRight: const Radius.circular(15),
                bottomLeft: const Radius.circular(15),
                topRight: Radius.circular(
                    chatMessageType == ChatMessageType.user ? 0 : 15),
                topLeft: Radius.circular(
                    chatMessageType == ChatMessageType.bot ? 0 : 15),
              )),
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: Dimensions.defaultTextSize * 1.5,
                  color: chatMessageType == ChatMessageType.bot
                      ? CustomColor.whiteColor
                      : Theme.of(context).primaryColor
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _userIcon() {
    return Expanded(
        flex: 0,
        child: chatMessageType == ChatMessageType.user
            ? LocalStorage.isLoggedIn()
                ? Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: Dimensions.widthSize),
                    child: CircleAvatar(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius * 5),
                        child: FadeInImage(
                          image: NetworkImage(controller.userModel.imageUrl),
                          placeholder: const AssetImage(Assets.smileSVG),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ))
                : Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: Dimensions.widthSize),
                    child: Image.asset(Assets.smileSVG))
            : IconButton(
                onPressed: onSpeech,
                icon: Obx(() => Icon(
                      Icons.record_voice_over_outlined,
                      color: controller.isSpeechLoading
                          ? controller.voiceSelectedIndex.value == index
                              ? CustomColor.primaryColor
                              : Get.isDarkMode ? Colors.white24 : Colors.black26
                          : Get.isDarkMode ? Colors.white24 : Colors.black26,
                    ))));
  }

  _robotIcon() {
    return Expanded(
        flex: 0,
        child: chatMessageType == ChatMessageType.bot
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: Dimensions.widthSize),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    Assets.bot,
                  ),
                ),
              )
            : SizedBox(width: Dimensions.widthSize * 5));
  }
}
