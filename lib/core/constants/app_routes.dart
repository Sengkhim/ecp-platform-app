// lib/core/constants/app_routes.dart

import 'package:get/get.dart';
import '../../data/providers/app_bindings.dart';
import '../../modules/orders/views/order_list_view.dart';
import '../../modules/orders/views/order_detail_view.dart';
import '../../modules/orders/views/create_order_view.dart';
import 'app_constants.dart';

class AppRoutes {
  AppRoutes._();

  static final pages = <GetPage>[
    GetPage(
      name: AppConstants.routeHome,
      page: () => const OrderListView(),
      binding: OrderListBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppConstants.routeOrders,
      page: () => const OrderListView(),
      binding: OrderListBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppConstants.routeOrderDetail,
      page: () => const OrderDetailView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.routeCreateOrder,
      page: () => const CreateOrderView(),
      binding: CreateOrderBinding(),
      transition: Transition.downToUp,
    ),
  ];
}
