import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/cancel_screen.dart';
import 'screens/card_form_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/failed_screen.dart';
import 'screens/methods_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/pending_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/redeem_screen.dart';
import 'screens/refund_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/success_screen.dart';
import 'screens/wallet_pay_screen.dart';

/// Payments routes. Checkout data travels via query params; each builder
/// parses `state.uri.queryParameters` and passes values as constructor args.
///
/// NOTE: OrdersScreen + VoltsWalletScreen are tab-nested under Profile —
/// the coordinator wires those; they are not listed here.
final List<RouteBase> paymentsRoutes = [
  GoRoute(
    path: '/payments/plans',
    builder: (BuildContext context, GoRouterState state) =>
        const PlansScreen(),
  ),
  GoRoute(
    path: '/payments/compare',
    builder: (BuildContext context, GoRouterState state) =>
        const CompareScreen(),
  ),
  GoRoute(
    path: '/payments/checkout',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return CheckoutScreen(courseId: q['courseId'], plan: q['plan']);
    },
  ),
  GoRoute(
    path: '/payments/methods',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return MethodsScreen(
        courseId: q['courseId'],
        plan: q['plan'],
        total: int.tryParse(q['total'] ?? ''),
        coupon: q['coupon'],
      );
    },
  ),
  GoRoute(
    path: '/payments/wallet',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return WalletPayScreen(
        courseId: q['courseId'],
        plan: q['plan'],
        total: int.tryParse(q['total'] ?? ''),
        coupon: q['coupon'],
        method: q['method'],
      );
    },
  ),
  GoRoute(
    path: '/payments/card',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return CardFormScreen(
        courseId: q['courseId'],
        plan: q['plan'],
        total: int.tryParse(q['total'] ?? ''),
        coupon: q['coupon'],
      );
    },
  ),
  GoRoute(
    path: '/payments/processing',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return ProcessingScreen(
        courseId: q['courseId'],
        plan: q['plan'],
        total: int.tryParse(q['total'] ?? ''),
        coupon: q['coupon'],
        method: q['method'],
      );
    },
  ),
  GoRoute(
    path: '/payments/success',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return SuccessScreen(
        courseId: q['courseId'],
        plan: q['plan'],
        total: int.tryParse(q['total'] ?? ''),
        coupon: q['coupon'],
        method: q['method'],
        invoice: q['invoice'],
      );
    },
  ),
  GoRoute(
    path: '/payments/failed',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return FailedScreen(
        courseId: q['courseId'],
        plan: q['plan'],
        total: int.tryParse(q['total'] ?? ''),
        coupon: q['coupon'],
        method: q['method'],
      );
    },
  ),
  GoRoute(
    path: '/payments/pending',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return PendingScreen(
        courseId: q['courseId'],
        plan: q['plan'],
        total: int.tryParse(q['total'] ?? ''),
        coupon: q['coupon'],
        method: q['method'],
        trxId: q['trxId'],
      );
    },
  ),
  GoRoute(
    path: '/payments/orders/:orderId',
    builder: (BuildContext context, GoRouterState state) =>
        OrderDetailScreen(orderId: state.pathParameters['orderId'] ?? ''),
  ),
  GoRoute(
    path: '/payments/subscription',
    builder: (BuildContext context, GoRouterState state) =>
        const SubscriptionScreen(),
  ),
  GoRoute(
    path: '/payments/cancel',
    builder: (BuildContext context, GoRouterState state) =>
        const CancelScreen(),
  ),
  GoRoute(
    path: '/payments/redeem',
    builder: (BuildContext context, GoRouterState state) =>
        const RedeemScreen(),
  ),
  GoRoute(
    path: '/payments/refund',
    builder: (BuildContext context, GoRouterState state) {
      final q = state.uri.queryParameters;
      return RefundScreen(orderId: q['orderId']);
    },
  ),
];
