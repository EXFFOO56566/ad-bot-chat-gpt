// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';

import '../services/in_app_purchase/singletones_data.dart';
import '../store_config.dart';
import '../utils/constants.dart';
import '../utils/custom_style.dart';
import '../utils/dimensions.dart';
import '../widgets/in_app_purchase/native_dialog.dart';
import '../widgets/in_app_purchase/paywall.dart';

class InAppPurchaseScreen extends StatefulWidget {
  const InAppPurchaseScreen({Key? key}) : super(key: key);

  @override
  _InAppPurchaseScreenState createState() => _InAppPurchaseScreenState();
}

class _InAppPurchaseScreenState extends State<InAppPurchaseScreen> {
  bool _isLoading = false;
  bool isLoading = false;
  late Offerings offerings;

  @override
  void initState() {
    initPlatformState();
    super.initState();
    setState(() {});
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


  _manageUser(String task, String newAppUserID) async {
    setState(() {
      _isLoading = true;
    });

    /*
      How to login and identify your users with the Purchases SDK.
            
      Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
    */

    try {
      if (task == "login") {
        await Purchases.logIn(newAppUserID);
      } else if (task == "logout") {
        await Purchases.logOut();
      } else if (task == "restore") {
        await Purchases.restorePurchases();
      }

      appData.appUserID = await Purchases.appUserID;
    } on PlatformException catch (e) {
      await showDialog(
          context: context,
          builder: (BuildContext context) => ShowDialogToDismiss(
              title: "Error", content: e.message!, buttonText: 'OK'));
    }

    setState(() {
      _isLoading = false;
    });
  }


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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.heightSize,
          horizontal: Dimensions.widthSize,
        ),

        child: TextButton(
          onPressed: perfomMagic,
          child: const Text('App Purchase'),
        ),
      ),

      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 32.0, right: 8.0, left: 8.0, bottom: 8.0),
                  child: Text(
                    'Current User Identifier',
                    textAlign: TextAlign.center,
                    style: CustomStyle.primaryTextStyle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  appData.appUserID,
                  textAlign: TextAlign.center,
                  style: CustomStyle.primaryTextStyle,
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(
                    top: 24.0, bottom: 8.0, left: 8.0, right: 8.0),
                child: Text(
                  'Subscription Status',
                  textAlign: TextAlign.center,
                  style: CustomStyle.primaryTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  appData.entitlementIsActive == true
                      ? 'Active'
                      : 'Not Active',
                  textAlign: TextAlign.center,
                  style: CustomStyle.primaryTextStyle.copyWith(
                      color: (appData.entitlementIsActive == true)
                          ? Colors.green
                          : Colors.red),
                ),
              ),
              Visibility(
                visible: appData.appUserID.contains("RCAnonymousID:"),
                child:  Padding(
                  padding: const EdgeInsets.only(
                      top: 24.0, bottom: 8.0, left: 8.0, right: 8.0),
                  child: Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: CustomStyle.primaryTextStyle,
                  ),
                ),
              ),
              Visibility(
                visible: appData.appUserID.contains("RCAnonymousID:"),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      style: CustomStyle.primaryTextStyle,
                      onSubmitted: (value) {
                        if (value != '') _manageUser('login', value);
                      },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  children: [
                    Visibility(
                      visible:
                      !appData.appUserID.contains("RCAnonymousID:"),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            _manageUser('logout', '');
                          },
                          child: Text(
                            "Logout",
                            style: CustomStyle.primaryTextStyle.copyWith(
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          _manageUser('restore', '');
                        },
                        child: Text(
                          "Restore Purchases",
                          style: CustomStyle.primaryTextStyle.copyWith(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
