import 'dart:convert';

import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/utils/http.dart';
import 'package:chatty/common/widgets/toast.dart';
import 'package:chatty/pages/frame/sign_in/state.dart';
import 'package:chatty/pages/frame/welcome/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInController extends GetxController {
  SignInController();

  @override
  void refresh() {

  } //final state = SignInState();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['openid'],
  );

  Future<void> handelSignIn({String? type}) async {
    try {
      if (type == "phone number") {
        if (kDebugMode) {
          print("Your logging in with phone number");
        }
      } else if (type == "google") {
        var user = await _googleSignIn.signIn();
        if (user != null) {
          String? displayName = user.displayName;
          String? email = user.email;
          String? id = user.id;
          String photoUrl = user.photoUrl ?? "assets/icons/google.png";
          LoginRequestEntity loginPanelListRequestEntity = LoginRequestEntity();
          loginPanelListRequestEntity.avatar = photoUrl;
          loginPanelListRequestEntity.name = displayName;
          loginPanelListRequestEntity.email = email;
          loginPanelListRequestEntity.open_id = id;
          loginPanelListRequestEntity.type = 2;
          print(jsonEncode(loginPanelListRequestEntity));
          asyncPostAllData(loginPanelListRequestEntity);
        }
      } else {
        print("Login in type is not sure");
      }
    } catch (e) {
      if (kDebugMode) {
        print("... Error with login $e");
      }
    }
  }

  asyncPostAllData(LoginRequestEntity loginRequestEntity) async {
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );
    var result = await UserAPI.Login(params: loginRequestEntity);
    if (result.code == 0) {
      print("this code 0 for creating +++++");
      await UserStore.to.saveProfile(result.data!);
      EasyLoading.dismiss();
    }else{
      EasyLoading.dismiss();
      toastInfo(msg: "Interneet Error");
    }
    Get.offAllNamed(AppRoutes.Message);
  }


}
