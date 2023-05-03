
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/pages/frame/message/state.dart';
import 'package:chatty/pages/frame/welcome/state.dart';
import 'package:get/get.dart';

class MessageController extends GetxController{
  MessageController();
  final state= MessageState();
  Future<void> goProfile() async {
   await Get.toNamed(AppRoutes.Profile);
  }


}