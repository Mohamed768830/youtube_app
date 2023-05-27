import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:youtube_app/modules/screens/authentication_screen/authentication_cubit/auth_state.dart';

import '../../../../shared/network/local_network.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  // Todo: API URL => https://student.valuxapps.com/api/
  // Todo: Register endpoint => register
  void register(
      {required String email,
      required String name,
      required String phone,
      required String password}) async {
    emit(RegisterLoadingState());
    try {
      Response response = await http.post(
        // request Url = base url + method url ( endpoint ) = https://student.valuxapps.com + /api/register
        Uri.parse('https://student.valuxapps.com/api/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'image': "jdfjfj" // الصوره مش شغاله بس لازم ابعت قيمه ك value
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true) {
          debugPrint("Response is : $data");
          emit(RegisterSuccessState());
        } else {
          debugPrint("Response is : $data");
          emit(FailedToRegisterState(message: data['message']));
        }
      }
    } catch (e) {
      debugPrint("Failed to Register , reason : $e");
      emit(FailedToRegisterState(message: e.toString()));
    }
  }

  // Account : mo.ha@gmail.com , password : 123456
  void login({required String email, required String password}) async {
    emit(LoginLoadingState());
    try {
      Response response = await http.post(
        // request => url = base url + method url
        Uri.parse('https://student.valuxapps.com/api/login'),
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          // debugPrint("User login success and his Data is : ${responseData['data']['token']}");
          await CacheNetwork.insertToCache(
              key: "token", value: responseData['data']['token']);
          emit(LoginSuccessState());
        } else {
          debugPrint("Failed to login, reason is : ${responseData['message']}");
          emit(FailedToLoginState(message: responseData['message']));
        }
      }
    } catch (e) {
      emit(FailedToLoginState(message: e.toString()));
    }
  }
}

/*
{
    "status": true,
    "message": "Registration done successfully",
    "data": {
        "name": "moo zaghloul",
        "email": "mhmd3@gmail.com",
        "phone": "01202517700",
        "id": 55647,
        "image": "https://student.valuxapps.com/storage/assets/defaults/user.jpg",
        "token": "vMAtbmRAPz4i7lTeFCZmI8z1NX7dfhnl7saaMOHqwXv6ZYwW4gXLmwl6Fug6BpqXCzCB11"
    }
}
 */
