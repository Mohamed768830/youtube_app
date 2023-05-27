import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:youtube_app/layout/layout_cubit/layout_state.dart';

import '../../models/banner_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../modules/screens/cart_screen.dart';
import '../../modules/screens/category_screen.dart';
import '../../modules/screens/favorites_screen.dart';
import '../../modules/screens/home_screen.dart';
import '../../modules/screens/profile_screen.dart';
import '../../shared/constant/constant.dart';

class LayoutCubit extends Cubit<LayoutStates> {
  LayoutCubit() : super(LayoutInitialState());

  int bottomNavIndex = 0;
  List<Widget> layoutScreens = [
    HomeScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen()
  ];
  void changeBottomNavIndex({required int index}) {
    bottomNavIndex = index;
    // Emit state
    emit(ChangeBottomNavIndexState());
  }

  UserModel? userModel;
  void getUserData() async {
    emit(GetUserDataLoadingState());
    Response response = await http.get(
        Uri.parse("https://student.valuxapps.com/api/profile"),
        headers: {'Authorization': token!, "lang": "en"});
    var responseData = jsonDecode(response.body);
    if (responseData['status'] == true) {
      userModel = UserModel.fromJson(data: responseData['data']);
      print("response is : $responseData");
      emit(GetUserDataSuccessState());
    } else {
      print("response is : $responseData");
      emit(FailedToGetUserDataState(error: responseData['message']));
    }
  }

  List<BannerModel> banners = [];
  void getBannersData() async {
    Response response =
        await http.get(Uri.parse("https://student.valuxapps.com/api/banners"));
    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      for (var item in responseBody['data']) {
        banners.add(BannerModel.fromJson(data: item));
      }
      emit(GetBannersSuccessState());
    } else {
      emit(FailedToGetBannersState());
    }
  }

  List<CategoryModel> categories = [];
  void getCategoriesData() async {
    Response response = await http.get(
        Uri.parse("https://student.valuxapps.com/api/categories"),
        headers: {'lang': "en"});
    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      for (var item in responseBody['data']['data']) {
        categories.add(CategoryModel.fromJson(data: item));
      }
      emit(GetCategoriesSuccessState());
    } else {
      emit(FailedToGetCategoriesState());
    }
  }

  List<ProductModel> products = [];
  void getProducts() async {
    Response response = await http.get(
        Uri.parse("https://student.valuxapps.com/api/home"),
        headers: {'Authorization': token!, 'lang': "en"});
    var responseBody = jsonDecode(response.body);

    /// print("Products Data is : $responseBody");
    // loop list
    if (responseBody['status'] == true) {
      for (var item in responseBody['data']['products']) {
        products.add(ProductModel.fromJson(data: item));
      }
      emit(GetProductsSuccessState());
    } else {
      emit(FailedToGetProductsState());
    }
  }

  // filtered products
  List<ProductModel> filteredProducts = [];
  void filterProducts({required String input}) {
    filteredProducts = products
        .where((element) =>
            element.name!.toLowerCase().startsWith(input.toLowerCase()))
        .toList();
    emit(FilterProductsSuccessState());
  }

  List<ProductModel> favorites = [];
  // set مفيش تكرار
  Set<String> favoritesID = {};
  Future<void> getFavorites() async {
    favorites.clear();
    Response response = await http.get(
        Uri.parse("https://student.valuxapps.com/api/favorites"),
        headers: {"lang": "en", "Authorization": token!});
    // http
    var responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      // loop list
      for (var item in responseBody['data']['data']) {
        // Refactoring
        favorites.add(ProductModel.fromJson(data: item['product']));
        favoritesID.add(item['product']['id'].toString());
      }
      print("Favorites number is : ${favorites.length}");
      emit(GetFavoritesSuccessState());
    } else {
      emit(FailedToGetFavoritesState());
    }
  }

  void addOrRemoveFromFavorites({required String productID}) async {
    Response response = await http.post(
        Uri.parse("https://student.valuxapps.com/api/favorites"),
        headers: {"lang": "en", "Authorization": token!},
        body: {"product_id": productID});
    var responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      if (favoritesID.contains(productID) == true) {
        // delete
        favoritesID.remove(productID);
      } else {
        // add
        favoritesID.add(productID);
      }
      await getFavorites();
      emit(AddOrRemoveItemFromFavoritesSuccessState());
    } else {
      emit(FailedToAddOrRemoveItemFromFavoritesState());
    }
  }

  List<ProductModel> carts = [];
  Set<String> cartsID = {};
  int totalPrice = 0;
  Future<void> getCarts() async {
    carts.clear();
    Response response = await http.get(
        Uri.parse("https://student.valuxapps.com/api/carts"),
        headers: {"Authorization": token!, "lang": "en"});
    var responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      // success
      for (var item in responseBody['data']['cart_items']) {
        cartsID.add(item['product']['id'].toString());
        carts.add(ProductModel.fromJson(data: item['product']));
      }
      totalPrice = responseBody['data']['total'];
      debugPrint("Carts length is : ${carts.length}");
      emit(GetCartsSuccessState());
    } else {
      // failed
      emit(FailedToGetCartsState());
    }
  }

  void addOrRemoveProductFromCart({required String id}) async {
    Response response = await http
        .post(Uri.parse("https://student.valuxapps.com/api/carts"), headers: {
      "lang": "en",
      "Authorization": token!,
    }, body: {
      "product_id": id
    });
    var responseBody = jsonDecode(response.body);
    if (responseBody["status"] == true) {
      if (cartsID.contains(id) == true) {
        cartsID.remove(id);
      } else {
        cartsID.add(id);
      }
      await getCarts();
      emit(AddOrRemoveItemFromCartSuccessState());
    } else {
      emit(AddOrRemoveItemFromCartFailedState());
    }
  }
}
