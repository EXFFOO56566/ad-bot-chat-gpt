import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/assets.dart';
import '../../utils/custom_color.dart';
import '../../utils/custom_style.dart';
import '../../utils/dimensions.dart';

class PrimaryInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onTap;


  const PrimaryInputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onTap,
  }) : super(key: key);

  @override
  State<PrimaryInputField> createState() => _PrimaryInputFieldState();
}

class _PrimaryInputFieldState extends State<PrimaryInputField> {

  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.widthSize * 1.2,
        vertical: Dimensions.heightSize * 1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: Dimensions.widthSize * 1.2,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                    color: focusNode!.hasFocus
                        ? CustomColor.primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    width: 1
                ),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(Dimensions.radius * 0.7),
              ),
              child: TextFormField(
                controller: widget.controller,
                style: CustomStyle.primaryTextStyle.copyWith(fontSize: Dimensions.defaultTextSize * 1.6),
                textAlign: TextAlign.left,
                onTap: (){
                  setState(() {
                    focusNode!.requestFocus();
                  });
                },
                onFieldSubmitted: (value){
                  setState(() {
                    focusNode!.unfocus();
                  });
                },
                focusNode: focusNode,
                decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: focusNode!.hasFocus
                          ? CustomColor.primaryColor.withOpacity(0.2)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      fontSize: Dimensions.defaultTextSize * 2,
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                ),

              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 0,
            child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: CustomColor.primaryColor,
                  child: Animator<double>(
                      duration: const Duration(milliseconds: 1000),
                      cycles: 0,
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: 15, end: 35),
                      builder: (context, animatorState, child) => SvgPicture.asset(
                        Assets.search,
                        height: animatorState.value,
                        width: animatorState.value,
                      )
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }
}
