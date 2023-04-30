import 'package:chatty/common/values/values.dart';
import 'package:chatty/pages/frame/welcome/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagePage extends GetView<WelcomeController> {
  MessagePage({super.key});

  Widget _buildPageHeadTitle({String? title}) {
    return Container(
      margin: EdgeInsets.only(
        top: 350.h,
      ),
      child: Text(
     "helllll",
        style:  TextStyle(
          color: AppColors.primaryElementText,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
          fontSize: 45.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryElement,
      body: Text("Hello world"),


    );
  }
}
