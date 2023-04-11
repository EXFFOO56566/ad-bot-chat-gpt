import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';



import '../helper/local_storage.dart';
import '../helper/notification_helper.dart';
import '../model/dalle_image_model/dalle_image_model.dart';
import '../utils/strings.dart';
import '../widgets/api/logger.dart';
import '../widgets/api/toast_message.dart';

var log = logger(ImageController);

class ImageController extends GetxController {
  var url = Uri.parse('https://api.openai.com/v1/images/generations');
  // ignore: non_constant_identifier_names


 

  // Rx<List<ImageModel>> image = Rx<List<ImageModel>>([]);

  late ImageModel _imageModel;
  ImageModel get imageModel => _imageModel;

  final _isVisible = false.obs;
  bool get isVisible => _isVisible.value;


  final data = ''.obs;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  Future getImage({required String imageText}) async {
    try {
      debugPrint("---------${count.value.toString()}-----------");
      debugPrint("---------${count.value.toString()}-----------");
      debugPrint("---------${count.value.toString()}-----------");

      _isLoading.value = true;
      _isVisible.value = true;
      update();

      var request = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getChatGptApiKey()}',
        },
        body: jsonEncode(
          {
            'prompt': imageText,
            'n': 10,
            "size": "256x256"
          },
        ),
      );
      if (request.statusCode == 200) {

        addCountImage();

        _imageModel = ImageModel.fromJson(jsonDecode(request.body));
        _isLoading.value = false;

      } else {
        _isLoading.value = false;
        ToastMessage.error('StatusCode Error');
        debugPrint(jsonDecode(request.body));
      }
    } catch (e) {
      _isLoading.value = false;
      ToastMessage.error('Error: $e');
      debugPrint(e.toString());
    }
  }


  RxString selectedValue = ''.obs;

  final List<String> moreList = [
    Strings.download.tr,
    Strings.share.tr
  ];

  void shareImage(BuildContext context, url, name) {

    Share.share(url, subject: "I'm sharing $name picture");
  }

  download(BuildContext context, String url) async{
    // Get.snackbar('Generated', "Please wait for load image");

    _isLoading.value = true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    late final Map<Permission, PermissionStatus> status;

    if(Platform.isAndroid){
      if(androidInfo.version.sdkInt <=32 ){
        status = await [
          Permission.storage
        ].request();
      }else{
        status = await [
          Permission.photos
        ].request();
      }
    }else{
      status = await [
        Permission.photosAddOnly
      ].request();
    }

    var allAccept = true;
    status.forEach((permission, status) { if(status != PermissionStatus.granted){
      allAccept = false;
    } });

    if (allAccept) {
      var response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      String picturesPath = url.substring(url.length - 20);
      log.i(picturesPath);
      final result = await SaverGallery.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          name: picturesPath,
          androidRelativePath: "Pictures/GeneratedImage");
      ToastMessage.success('Image downloaded at gallery');
      log.i(result.toString());
    } else {
      ToastMessage.error('Permission not granted');
    }

    _isLoading.value = false;

  }



  @override
  void onInit() {
    NotificationHelper.initInfo();
    count.value = LocalStorage.getImageCount();
    super.onInit();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance; // firebase instance/object
  User get user => _auth.currentUser!;
  RxInt count = 0.obs;
  //count.value = LocalStorage.getTextCount();
  addCountImage() async {

    count.value++;
    LocalStorage.saveImageCount(count: count.value);

    debugPrint("---------${count.value.toString()}-----------");
    debugPrint("---------${count.value.toString()}-----------");
    debugPrint("---------${count.value.toString()}-----------");

    await FirebaseFirestore.instance
        .collection('adbotUsers')
        .doc(user.uid)
        .update({
      "imageCount": count.value
    });
  }
}