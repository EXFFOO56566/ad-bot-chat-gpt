// ignore_for_file: deprecated_member_use
import 'package:adbot/widgets/api/toast_message.dart';

import '../utils/Flutter%20Theam/themes.dart';
import '../utils/custom_style.dart';
import '../utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:simple_animations/simple_animations.dart';

import '../controller/home_controller.dart';
import '../helper/admob_helper.dart';
import '../helper/local_storage.dart';
import '../routes/routes.dart';
import '../utils/assets.dart';
import '../utils/constants.dart';
import '../utils/custom_color.dart';
import '../utils/strings.dart';
import '../widgets/inputs_widgets/secondary_input_field.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    RxBool isDark = Get.isDarkMode.obs;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Visibility(
            visible: LocalStorage.isLoggedIn(),
            child: IconButton(
              onPressed: () {
                _showMenuDialog(context);
              },
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _pageIconAnTitle(),
          _buttonsWidget(context, isDark),
          SizedBox(height: Dimensions.heightSize * 4)
        ],
      ),
      floatingActionButton: _floatingActionButton(isDark),
    );
  }

  _floatingActionButton(RxBool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: FloatingActionButton(
        onPressed: () {
          Themes().switchTheme();
          isDark.value = !isDark.value;

          if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            debugPrint('----------------------');
            AdMobHelper.getInterstitialAdLoad();
            debugPrint('----------------------');
          }

        },
        backgroundColor: CustomColor.primaryColor,
        child: Obx(() => Icon(
              isDark.value
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: CustomColor.whiteColor,
              size: 35,
            )),
      ),
    );
  }

  _buttonsWidget(BuildContext context, isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _showDialog(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize * 2,
                vertical: Dimensions.heightSize * 0.7),
            width: MediaQuery.of(context).size.width * 0.5,
            margin: EdgeInsets.symmetric(vertical: Dimensions.heightSize * 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor).withOpacity(0.05),
              borderRadius: BorderRadius.circular(Dimensions.radius * 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Obx(() => Text(
                  controller.selectedLanguage.value.tr,
                  style: TextStyle(
                      fontSize: Dimensions.defaultTextSize * 1.8,
                      fontWeight: FontWeight.w500,
                      color: (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor)),
                )),
                SizedBox(width: Dimensions.widthSize * .7),
                Icon(
                  Icons.arrow_drop_down,
                  color: (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor),
                )
              ],
            ),
          ),
        ),

        Visibility(
          visible: LocalStorage.getChatStatus(),
            child: _buildContainer(context, isDark,
            title: Strings.chatWithAdBot.tr,
            subTitle: Strings.chatWithAdBotSubTitle.tr,
            iconPath: Assets.chat, onTap: () {

              if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            AdMobHelper.getInterstitialAdLoad();
          }


              if(LocalStorage.showAdPermissioned()){
              Get.toNamed(Routes.chatScreen);
            }else{
              if(LocalStorage.getTextCount() <=  50){
                Get.toNamed(Routes.chatScreen);
              }else{
                ToastMessage.error('Chat limit is over.\nBuy Subscription for continue');
              }
            }

        })),

        Visibility(
          visible: LocalStorage.getImageStatus(),
            child: _buildContainer(context, isDark,
            title: Strings.generateAnyImage.tr,
            subTitle: Strings.generateAnyImageSubTitle.tr,
            iconPath: Assets.image, onTap: () {

              if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            AdMobHelper.getInterstitialAdLoad();
          }

              if(LocalStorage.showAdPermissioned()){
                Get.toNamed(Routes.searchScreen);
              }else{
                if(LocalStorage.getImageCount() <=  10){
                  Get.toNamed(Routes.searchScreen);
                }else{
                  ToastMessage.error('Image limit is over.\nBuy Subscription for continue');
                }
              }

        })),

        Visibility(
          visible: LocalStorage.getAdMobStatus(),
            child: _adShowWidget()),

        SizedBox(height: Dimensions.heightSize),

        Visibility(
          visible: LocalStorage.isLoggedIn(),
          child: TextButton.icon(
              onPressed: (){
                if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            AdMobHelper.getInterstitialAdLoad();
          }
                controller.logout();
              },
              icon: const Icon(
                Icons.logout,
                color: CustomColor.primaryColor,
              ),
              label: Text(Strings.logOut.tr,
                style: const TextStyle(
                    color: CustomColor.primaryColor),
              )
          ),
        )
      ],
    );
  }

  _adShowWidget() {
    RxBool  visible = LocalStorage.showAdPermissioned().obs;
    return Obx(() =>Visibility(
      visible: visible.value,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: AdWidget(
              ad: AdMobHelper.getBannerAd()..load(),
              key: UniqueKey(),
            ),
          ),

        ],
      ),
    ));
  }

  _pageIconAnTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          Assets.bot,
          scale: 6,
        ),
        _animatedTextWidget(),
      ],
    );
  }

  _animatedTextWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: languageStateName == 'Arabic'
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PlayAnimationBuilder(
                  tween: IntTween(begin: 0, end: 3),
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Text(
                      'bot'.substring(0, value),
                      style: TextStyle(
                          fontSize: Dimensions.defaultTextSize * 3.2,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor),
                    );
                  },
                ),
                PlayAnimationBuilder(
                  tween: IntTween(begin: 0, end: 2),
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Text(
                      'ad'.substring(0, value),
                      style: TextStyle(
                          fontSize: Dimensions.defaultTextSize * 3.2,
                          fontWeight: FontWeight.w400,
                          color: CustomColor.primaryColor),
                    );
                  },
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayAnimationBuilder(
                  tween: IntTween(begin: 0, end: 2),
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Text(
                      'ad'.substring(0, value),
                      style: TextStyle(
                        fontSize: Dimensions.defaultTextSize * 6.2,
                        fontWeight: FontWeight.bold,
                        color: CustomColor.primaryColor,
                      ),
                    );
                  },
                ),
                PlayAnimationBuilder(
                  tween: IntTween(begin: 0, end: 3),
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Text(
                      'bot'.substring(0, value),
                      style: TextStyle(
                        fontSize: Dimensions.defaultTextSize * 6.2,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  _buildContainer(BuildContext context, isDark,
      {required String title,
      required String subTitle,
      required VoidCallback onTap,
      required String iconPath}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.5),
        margin: EdgeInsets.symmetric(
          vertical: Dimensions.heightSize * 0.8,
          horizontal: Dimensions.widthSize * 3,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(
                color: (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor).withOpacity(0.4),
                width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 40,
                width: 50,
                child: SvgPicture.asset(
                  iconPath,
                  color: (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor),
                )),
            // Visibility(
            //   visible: isPNG,
            //   child: Expanded(
            //       flex: 0,
            //       child: Image.asset(
            //         iconPath,
            //         color: (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor),
            //         scale: 18,
            //       )),
            // ),
            SizedBox(width: Dimensions.widthSize),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor),
                        fontWeight: FontWeight.w600,
                        fontSize: Dimensions.defaultTextSize * 2),
                  ),
                  SizedBox(height: Dimensions.heightSize * 0.5),
                  Text(
                    subTitle,
                    style: TextStyle(
                        color:
                        (isDark.value ? CustomColor.whiteColor : CustomColor.primaryColor).withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                        fontSize: Dimensions.defaultTextSize * 1.2),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
                              if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            AdMobHelper.getInterstitialAdLoad();
          }


                              controller.onChangeLanguage(
                                  controller.moreList[index], index);
                              Get.back();
                            },
                            child: Text(
                              controller.moreList[index].tr,
                              style: TextStyle(
                                  color: controller.selectedLanguage.value ==
                                          controller.moreList[index]
                                      ? CustomColor.primaryColor
                                      : CustomColor.blackColor),
                            )),
                      )),
            ),
          );
        });
  }


  _supportField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: Dimensions.heightSize * 2,
        left: Dimensions.widthSize * 2,
        right: Dimensions.widthSize * 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Text(
            Strings.faceAnyProblem.tr,
            style: CustomStyle.primaryTextStyle.copyWith(
                fontSize: Dimensions.defaultTextSize * 2
            ),
          ),

          SecondaryInputField(
            controller: controller.loginController.nameController,
            hintText: Strings.enterYourName,
          ),
          SecondaryInputField(
            controller: controller.loginController.emailController,
            hintText: Strings.enterYourEmail,
          ),

          SecondaryInputField(
            controller: controller.loginController.noteController,
            hintText: Strings.describeYourIssue,
            maxLine: 3,
          ),

          GestureDetector(
            onTap: (){
              if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            AdMobHelper.getInterstitialAdLoad();
          }


              if(
              controller.loginController.nameController.text.isNotEmpty &&
                  controller.loginController.emailController.text.isNotEmpty &&
                  controller.loginController.noteController.text.isNotEmpty
              ){
                Get.back();
                controller.loginController.sendSupportTicket(
                    name: controller.loginController.nameController.text,
                    email: controller.loginController.emailController.text,
                    note: controller.loginController.noteController.text
                );
              }
              else{
                ToastMessage.error('!! Fill the Form');
              }

            },
            child: Card(
              color: CustomColor.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions. radius * 2)
              ),

              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    vertical: Dimensions.heightSize
                ),
                child: const Icon(
                  Icons.send_outlined,
                  color: CustomColor.whiteColor,
                ),
              ),
            ),
          ),


          SizedBox(
            height: Dimensions.heightSize,
          )


        ],
      ),
    );
  }



  _showMenuDialog(BuildContext context) {
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
                  controller.menuList.length,
                      (index) => Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.widthSize * 1,
                        vertical: Dimensions.heightSize * 0.5),
                    child: TextButton(
                        onPressed: () {

                          if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
                              AdMobHelper.getInterstitialAdLoad();
                            }


                          if(index == 0){
                            Get.back();
                            debugPrint('index 0');
                            showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(Dimensions.radius * 2),
                                      topRight: Radius.circular(Dimensions.radius * 2),
                                    )
                                ),
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return _supportField(context);
                                });
                          }else if(index == 1){
                            Get.back();
                            showAlertDialog(context);
                          }

                        },
                        child: Text(
                          controller.menuList[index].tr,
                          style: const TextStyle(
                              color: CustomColor.blackColor),
                        )),
                  )),
            ),
          );
        });
  }

  void showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = TextButton(
      child: const Text(
          "OK"
      ),
      onPressed: () {
        Get.back();
        if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            AdMobHelper.getInterstitialAdLoad();
          }
        controller.deleteAccount();
      },
    );

    Widget cancelButton = TextButton(
      child: Text(
        Strings.cancel.tr,
        style: const TextStyle(
            color: Colors.red
        ),
      ),
      onPressed: () {
        Get.back();
        if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
            AdMobHelper.getInterstitialAdLoad();
          }
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
          Strings.alert.tr,
        style: const TextStyle(
          color: Colors.red
        ),
      ),
      content: Text(
        Strings.deleteYourAccount.tr,
        style: const TextStyle(
          color: CustomColor.primaryColor
        ),
      ),
      actions: [
        okButton,
        cancelButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
