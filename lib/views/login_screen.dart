import 'package:adbot/utils/custom_style.dart';
import 'package:adbot/widgets/api/toast_message.dart';
import 'package:animator/animator.dart';
import '../widgets/api/custom_loading_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';

import '../controller/login_controller.dart';
import '../utils/assets.dart';
import '../utils/constants.dart';
import '../utils/custom_color.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/inputs_widgets/secondary_input_field.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({Key? key}) : super(key: key);

  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
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
            },
            icon: Icon(
              Icons.help_outline_outlined,
              color: Theme.of(context).primaryColor,
            ),
          )
        ],
      ),
      body: Obx(() => controller.isLoading
          ? const CustomLoadingAPI()
          : _bodyWidget(context)),
    );
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
            controller: controller.nameController,
            hintText: Strings.enterYourName.tr,
          ),
          SecondaryInputField(
            controller: controller.emailController,
            hintText: Strings.enterYourEmail.tr,
          ),

          SecondaryInputField(
            controller: controller.noteController,
            hintText: Strings.describeYourIssue.tr,
            maxLine: 3,
          ),

          GestureDetector(
            onTap: (){
              if(
              controller.nameController.text.isNotEmpty &&
              controller.emailController.text.isNotEmpty &&
              controller.noteController.text.isNotEmpty
              ){
                Get.back();
                controller.sendSupportTicket(
                    name: controller.nameController.text,
                    email: controller.emailController.text,
                    note: controller.noteController.text
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

  _bodyWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.bot,
              scale: 6,
            ),
            Padding(
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
            ),
          ],
        ),
        Column(
          children: [
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.5),
              margin: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize * 3,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                  border:
                      Border.all(color: CustomColor.primaryColor, width: 1)),
              child: InkWell(
                onTap: () {
                  controller.signInWithGoogle(context);
                },
                borderRadius: BorderRadius.circular(Dimensions.radius),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(Assets.google),
                    SizedBox(width: Dimensions.widthSize * 2),
                    PlayAnimationBuilder(
                      tween: IntTween(begin: 0, end: Strings.google.tr.length),
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Text(
                          Strings.google.tr.substring(0, value),
                          style: TextStyle(
                              color: CustomColor.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: Dimensions.defaultTextSize * 1.8),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Container(
            //   alignment: Alignment.center,
            //   width: double.infinity,
            //   padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.5),
            //   margin: EdgeInsets.symmetric(
            //     horizontal: Dimensions.widthSize * 3,
            //   ),
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(Dimensions.radius),
            //       border:
            //           Border.all(color: CustomColor.primaryColor, width: 1)),
            //   child: InkWell(
            //     onTap: () {
            //       controller.signInWithFacebook(context);
            //     },
            //     borderRadius: BorderRadius.circular(Dimensions.radius),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Image.asset(Assets.facebook),
            //         SizedBox(width: Dimensions.widthSize * 2),
            //         PlayAnimationBuilder(
            //           tween:
            //               IntTween(begin: 0, end: Strings.facebook.tr.length),
            //           duration: const Duration(milliseconds: 1000),
            //           delay: const Duration(milliseconds: 200),
            //           builder: (context, value, child) {
            //             return Text(
            //               Strings.facebook.tr.substring(0, value),
            //               style: TextStyle(
            //                   color: CustomColor.primaryColor,
            //                   fontWeight: FontWeight.w500,
            //                   fontSize: Dimensions.defaultTextSize * 1.8),
            //             );
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: Dimensions.heightSize),
            TextButton(
                onPressed: () {
                  controller.goToHomePage();
                },
                child: Animator<double>(
                    duration: const Duration(milliseconds: 1000),
                    cycles: 0,
                    curve: Curves.easeInOut,
                    tween: Tween<double>(begin: 12.0, end: 14.0),
                    builder: (context, animatorState, child) {
                      return Text(
                        Strings.continueAsGuest.tr,
                        style: TextStyle(
                            color: CustomColor.primaryColor,
                            fontSize: animatorState.value),
                      );
                    })),
          ],
        ),
      ],
    );
  }
}
