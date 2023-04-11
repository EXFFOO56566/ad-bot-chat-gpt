import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../helper/local_storage.dart';
import '../routes/routes.dart';
import '../utils/config.dart';
import '../widgets/api/toast_message.dart';

class StripeService {
  Map<String, dynamic>? paymentIntentData;

  // var stripeSecretKey = LocalStorage.getStripeClientId();
  var stripeSecretKey = ApiConfig.stripeSecretKey;


  Future<void> makePayment({
    required String amount, required String currency
  }) async{
    try{
      debugPrint("Start Payment");
      paymentIntentData = await createPaymentIntent(amount, currency);

      debugPrint("After payment intent");

      if(paymentIntentData != null){
        // CardEditController cardEditController = CardEditController(
        //   initialDetails: CardFieldInputDetails(
        //     complete: true,
        //     number: '4312424253534242',
        //     cvc: '234',
        //     expiryMonth: 3,
        //     expiryYear: 2024,
        //   )
        // );
        // await Stripe.buildWebCard(
        //   controller: cardEditController,
        // );

        debugPrint(" payment intent is not null .........");
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              customFlow: true,
              merchantDisplayName: 'Prospects',
              customerId: paymentIntentData!['customer'],
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92'),
              googlePay: const PaymentSheetGooglePay(merchantCountryCode: '+92', testEnv: true),
              style: ThemeMode.dark,
            )
        );
        debugPrint(" initPaymentSheet  .........");
        displayPaymentSheet();
      }
    }catch(e, s){
      debugPrint("After payment intent Error: ${e.toString()}");
      debugPrint("After payment intent s Error: ${s.toString()}");
    }
  }

  displayPaymentSheet() async{
    try{
      await Stripe.instance.presentPaymentSheet();
      ToastMessage.success('Payment Successful');
      updateUserPlan();
    }on Exception catch(e){
      if(e is StripeException){
        debugPrint("Error from Stripe: ${e.error.localizedMessage}");
      }else{
        debugPrint("Unforcen Error: $e");
      }
    } catch(e){
      debugPrint("Exception $e");
    }
  }

  createPaymentIntent(
      String amount,
      String currency) async{
    try{
      Map<String, dynamic> body = {
        'amount': calculate(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };


      debugPrint("Start Payment Intent http rwq post method");


      var response = await http.post(
        Uri.parse(ApiConfig.stripeUrl) ,
        body: body,
        headers: {
          "Authorization": "Bearer $stripeSecretKey",
          "Content-Type": 'application/x-www-form-urlencoded'
        }
      );
      debugPrint("End Payment Intent http rwq post method");
      debugPrint(response.body.toString());

      return jsonDecode(response.body);
    }catch(e){
      debugPrint('err charging user: ${e.toString()}');
    }
  }


  calculate(String amount){
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }




  updateUserPlan() async {
    var collection = FirebaseFirestore.instance.collection('adbotUsers');
    collection.doc(LocalStorage.getId()).update({'isPremium': true});
    ToastMessage.success('Your Plan Updated to Premium');
    LocalStorage.showAdYes(isShowAdYes: false);
    Get.offNamedUntil(Routes.homeScreen, (route) => false);
  }
}