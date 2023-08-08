import "package:get/get.dart";

import "../modules/home/bindings/home_binding.dart";
import "../modules/home/views/home_view.dart";
import "../modules/settings/bindings/settings_binding.dart";
import "../modules/settings/views/settings_view.dart";
import '../modules/conversation/bindings/conversation_binding.dart';
import '../modules/conversation/views/conversation_view.dart';
import '../modules/service/bindings/service_binding.dart';
import '../modules/service/views/service_view.dart';
import '../modules/vendor/bindings/vendor_binding.dart';
import '../modules/vendor/views/vendor_view.dart';

part "app_routes.dart";

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.VENDOR,
      page: () => const VendorView(),
      binding: VendorBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE,
      page: () => const ServiceView(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: _Paths.CONVERSATION,
      page: () => const ConversationView(),
      binding: ConversationBinding(),
    ),
  ];
}
