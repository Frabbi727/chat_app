import 'package:chatty/common/values/values.dart';
import 'package:chatty/pages/frame/message/controller.dart';
import 'package:chatty/pages/frame/welcome/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagePage extends GetView<MessageController> {
  MessagePage({super.key});

  Widget _headBar() {
    return Center(
      child: Container(
        width: 320.w,
        height: 44.h,
        margin: EdgeInsets.only(bottom: 20.h, top: 20.h),
        child: Row(
          children: [
            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                        color: AppColors.primarySecondaryBackground,
                        borderRadius: BorderRadius.all(Radius.circular(22.r)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ]),
                    child: controller.state.head_detail.value.avatar == null
                        ? Image(
                            image:
                                AssetImage("assets/images/account_header.png"))
                        : Text("Hi"),
                  ),
                  onTap: (){
                    controller.goProfile();
                  },
                ),
                Positioned(
                  bottom: 5.h,
                  right: 0.w,
                  height: 14.h,
                  child: Container(
                    width: 14.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.w,
                        color: AppColors.primaryElementText,
                      ),
                      color: AppColors.primaryElementStatus,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: _headBar(),
              )
            ],
          ),
        ],
      )),
    );
  }
}
