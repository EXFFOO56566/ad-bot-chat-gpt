// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';


import '../helper/local_storage.dart';
import '../services/in_app_purchase/singletones_data.dart';
import '../store_config.dart';
import '../utils/constants.dart';
import '../controller/plan_controller.dart';
import '../routes/routes.dart';
import '../services/stripe_service.dart';
import '../utils/assets.dart';
import '../utils/custom_color.dart';
import '../utils/custom_style.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/appbar/appbar_widget2.dart';
import '../widgets/in_app_purchase/native_dialog.dart';
import '../widgets/in_app_purchase/paywall.dart';
import 'payment_method/paypal_payment.dart';

class PurchasePlanScreen extends StatefulWidget {
  const PurchasePlanScreen({Key? key}) : super(key: key);

  @override
  State<PurchasePlanScreen> createState() => _PurchasePlanScreenState();
}

class _PurchasePlanScreenState extends State<PurchasePlanScreen> {
  bool isLoading = false;
  late Offerings offerings;


  /*
    We should check if we can magically change the weather
    (subscription active) and if not, display the paywall.
  */
  void perfomMagic() async {
    setState(() {
      isLoading = true;
    });

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    if (customerInfo.entitlements.all[entitlementID] != null &&
        customerInfo.entitlements.all[entitlementID]?.isActive == true) {
      // appData.currentData = WeatherData.generateData();

      setState(() {
        isLoading = false;
      });
    }
    else {
      try {
        offerings = await Purchases.getOfferings();
      } on PlatformException catch (e) {
        await showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
                title: "Error", content: e.message ?? '', buttonText: 'OK'));
      }

      setState(() {
        isLoading = false;
      });

      if (offerings.current == null) {
        // offerings are empty, show a message to your user
      } else {
        // current offering is available, show paywall
        await showModalBottomSheet(
          useRootNavigator: true,
          isDismissible: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Paywall(
                    offering: offerings.current!,
                  );
                });
          },
        );
      }
    }
  }



  final controller = Get.put(PlanController());
  var paymentController = StripeService();

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }


  Future<void> initPlatformState() async {
    // Enable debug logs before calling `configure`.
    await Purchases.setLogLevel(LogLevel.debug);

    /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK. Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids

    - observerMode is false, so Purchases will automatically handle finishing transactions. Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
    PurchasesConfiguration configuration;
    if (StoreConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
    } else {
      configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
    }
    await Purchases.configure(configuration);

    appData.appUserID = await Purchases.appUserID;

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      appData.appUserID = await Purchases.appUserID;

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      (customerInfo.entitlements.all[entitlementID] != null &&
          customerInfo.entitlements.all[entitlementID]!.isActive)
          ? appData.entitlementIsActive = true
          : appData.entitlementIsActive = false;

      setState(() {});
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget2(
        context: context,
        appTitle: Strings.subscriptionPlan.tr,
        onTap: () {
          Get.toNamed(Routes.homeScreen);
        },
      ),
      body: _bodyWidget(context),
      // bottomNavigationBar: Container(
      //   padding: EdgeInsets.symmetric(
      //     vertical: Dimensions.heightSize,
      //     horizontal: Dimensions.widthSize,
      //   ),
      //
      //   child: TextButton(
      //     onPressed: perfomMagic,
      //     child: const Text('App Purchase'),
      //   ),
      // ),
    );
  }

  _bodyWidget(BuildContext context) {
    return GetBuilder(
      builder: (PlanController controller) {
        return Column(
          children: [
            _purchaseWidget(
              onTap: () {
                // controller.updateUserPlan();
                Get.toNamed(Routes.homeScreen);

              },
              color: CustomColor.secondaryColor,
              title: Strings.freeSubscription.tr,
              price: '0.00',
              support: Strings.notIncluded.tr,
              firstService: Strings.limitedChatting.tr,
              secondService: '',
            ),
            _purchaseWidget(
              onTap: () {
                _showDialog(context);
              },
              color: CustomColor.secondaryColor2,
              title: Strings.premiumSubscription.tr,
              price: '9.00',
              visible: true,
              support: '24/7',
              firstService: Strings.unlimitedChatting.tr,
              secondService: Strings.unlimitedImage.tr,
            ),
          ],
        );
      },
    );
  }

  _purchaseWidget({
    required VoidCallback onTap,
    required Color color,
    required String title,
    required String price,
    required String support,
    required String firstService,
    required String secondService,
    bool visible = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
            horizontal: Dimensions.widthSize * 2,
            vertical: Dimensions.heightSize),
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.widthSize * 2,
            vertical: Dimensions.heightSize * 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(Dimensions.radius * 3),
              bottomLeft: Radius.circular(Dimensions.radius * 3),
            ),
            color: color.withOpacity(Get.isDarkMode ? 0.03 : 1),
            border: Border.all(
                width: 2, color: color.withOpacity(Get.isDarkMode ? 0.08 : 1))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 2,
                  color: Get.isDarkMode ? color : Colors.white),
            ),
            SizedBox(
              height: Dimensions.heightSize,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "\$ $price",
                  style: CustomStyle.primaryTextStyle.copyWith(
                      fontSize: Dimensions.defaultTextSize * 4,
                      color: Get.isDarkMode ? color : Colors.white,
                      fontWeight: FontWeight.w700),
                ),
                Visibility(
                  visible: visible,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Dimensions.widthSize * .5,
                      ),
                      Container(
                        height: Dimensions.heightSize * 2,
                        width: 2,
                        color: Get.isDarkMode ? color : Colors.white,
                      ),
                      SizedBox(
                        width: Dimensions.widthSize * .5,
                      ),
                      Text(
                        Strings.perMonth.tr,
                        style: CustomStyle.primaryTextStyle.copyWith(
                          fontSize: Dimensions.defaultTextSize * 1.4,
                          color: Get.isDarkMode ? color : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Dimensions.heightSize * .5,
            ),
            Text(
              '${Strings.freeSupport.tr} $support',
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 1.2,
                  color: Get.isDarkMode
                      ? color.withOpacity(0.8)
                      : Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: Dimensions.heightSize * 1,
            ),
            Text(
              "• $firstService",
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 1.4,
                  color: Get.isDarkMode ? color : Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: Dimensions.heightSize * .5,
            ),
            Text(
              "• $secondService",
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 1.4,
                  color: Get.isDarkMode ? color : Colors.white,
                  fontWeight: FontWeight.w500),
            ),
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
                  controller.paymentMethod.length,
                      (index) => Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.widthSize * 1,
                        vertical: Dimensions.heightSize * 0.5),
                    child: TextButton(
                        onPressed: (){
                          controller.selectedMethod.value = controller.paymentMethod[index];
                          paymentPressedFunction(index);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                                index == 0
                                    ? Assets.paypal
                                    : Assets.stripe ,
                              scale: 3
                            ),
                            SizedBox(
                              width: Dimensions.widthSize,
                            ),
                            Text(
                              controller.paymentMethod[index],
                              style: const TextStyle(
                                  color: CustomColor.blackColor),
                            ),
                          ],
                        )),
                  )),
            ),
          );
        });
  }

  void paymentPressedFunction(int index) {
    if (index == 0) {
      debugPrint("WORKED PAYPAL");
      Get.back();
      debugPrint("WORKED PAYPAL");
      if(LocalStorage.getPaypalStatus()){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => PaypalPayment(
              onFinish: (number) async {
                controller.updateUserPlan();
              },
            ),
          ),
        );
      }else{
        Get.snackbar("Alert!", 'Paypal is not active.');
      }
    }
    else if (index == 1) {
      if(LocalStorage.getPaypalStatus()){
        paymentController.makePayment(amount: '9', currency: 'USD');
        Get.back();
      }else{
        Get.snackbar("Alert!", 'Stripe is not active.');
      }
    }
  }
}
