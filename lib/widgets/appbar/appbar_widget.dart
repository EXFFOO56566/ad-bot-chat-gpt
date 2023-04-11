import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../utils/assets.dart';
import '../../utils/dimensions.dart';

// ignore_for_file: deprecated_member_use
class AppBarWidget extends AppBar {
  final BuildContext context;
  final bool moreVisible;
  final String appTitle;
  final VoidCallback onPressed, onBackClick;
  AppBarWidget(
      {super.key,
      required this.appTitle,
      required this.context,
      required this.onBackClick,
      this.moreVisible = true,
      required this.onPressed})
      : super(
          backgroundColor: Colors.transparent,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appTitle.tr,
                style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontSize: Dimensions.defaultTextSize * 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            Visibility(
              visible: moreVisible,
              child: IconButton(
                  onPressed: onPressed,
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).backgroundColor)),
            )
          ],
          leading: IconButton(
              onPressed: onBackClick,
              icon: SvgPicture.asset(
                Assets.backSVG,
                color: Theme.of(context).backgroundColor,
              )),
        );
}
