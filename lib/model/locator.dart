import 'package:get_it/get_it.dart';
import 'package:sirius_geo_4/model/main_model.dart';

class AppInfo {
  String get welcomeMessage => 'Welcome to Sirius Geo App';
}

GetIt locator = GetIt.asNewInstance();

void setupLocator() {
  locator.registerFactory(() => AppInfo());

  locator.registerLazySingleton<MainModel>(() => MainModel());
}

final MainModel model = locator<MainModel>();
