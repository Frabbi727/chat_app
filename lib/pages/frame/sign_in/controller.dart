
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/pages/frame/sign_in/state.dart';
import 'package:chatty/pages/frame/welcome/state.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInController extends GetxController{
  SignInController();
  final state= SignInState();

  final GoogleSignIn _googleSignIn= GoogleSignIn(
    scopes: [
      'openid'
    ],

  );

  Future<void> handelSignIn({String? type}) async {
    try{
      if(type=="phone number"){
        if(kDebugMode){
          print("Your logging in with phone number");
        }

      }else if(type=="google"){
      var user=  await _googleSignIn.signIn();
      if(user!=null){
        String? displayName= user.displayName;
        String? email= user.email;
        String? id= user.id;
        String photoUrl= user.photoUrl??"assets/icons/google.png";
        LoginRequestEntity loginPanelListRequestEntity=LoginRequestEntity();
        loginPanelListRequestEntity.avatar=photoUrl;
        loginPanelListRequestEntity.name=displayName;
        loginPanelListRequestEntity.email=email;
        loginPanelListRequestEntity.open_id=id;
        loginPanelListRequestEntity.type=2;
        asyncPostAllData();
      }
      }else{
        print("Login in type is not sure");
      }

    }catch(e){
      if(kDebugMode){
        print("... Error with login $e");
      }
    }
  }

  asyncPostAllData(){
    print(".... Lets go to message page....>>");
    UserStore.to.setIsLogin=true;
    Get.offAllNamed(AppRoutes.Message);

  }



}