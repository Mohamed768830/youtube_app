import 'package:get_it/get_it.dart';
import 'package:youtube_app/layout/layout_cubit/layout_cubit.dart';
import 'package:youtube_app/modules/screens/authentication_screen/authentication_cubit/auth_cubit.dart';

final getIt = GetIt.instance;

class ServicesLocator {
  void init() {
    //Cubit
    getIt.registerFactory<LayoutCubit>(() => LayoutCubit());
    getIt.registerFactory<AuthCubit>(() => AuthCubit());
  }
}
