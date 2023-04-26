
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/pages/frame/welcome/state.dart';
import 'package:get/get.dart';

class MessageController extends GetxController{
  MessageController();
  final title= "Chatty .";
  final state= WelcomeState();

  @override
  void onReady(){
    super.onReady();


  }


}