import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../data/demo_data.dart';
import '../../theme/app_colors.dart';

/// Shared helpers for the payments feature: pricing, query-string

/// Monthly price of Shikhi Pro in taka.
const int proMonthlyPrice = 499;

/// Demo wallet number shown on the wallet-pay screen.
const String demoWalletNumber = '01712-345678';

/// Demo subscription renewal date.
const String demoRenewDate = '12 Dec 2026';

/// Builds a URL query string from non-null, non-empty params.
String buildQuery(Map<String, String?> params) {
  final clean = <String, String>{};
  for (final entry in params.entries) {
    final value = entry.value;
    if (value != null && value.isNotEmpty) clean[entry.key] = value;
  }
  return Uri(queryParameters: clean).query;
}

/// Appends [params] to [path]; returns [path] unchanged when empty.
String withQuery(String path, Map<String, String?> params) {
  final query = buildQuery(params);
  return query.isEmpty ? path : '$path?$query';
}

/// The checkout params every payment step passes along.
Map<String, String?> checkoutParams({
  String? courseId,
  String? plan,
  int? total,
  String? coupon,
  String? method,
  String? trxId,
  String? invoice,
}) =>
    {
      'courseId': courseId,
      'plan': plan,
      'total': total?.toString(),
      'coupon': coupon,
      'method': method,
      'trxId': trxId,
      'invoice': invoice,
    };

/// Display title of the item being bought.
String itemTitle({String? courseId, String? plan}) {
  if (plan == 'pro') return 'Shikhi Pro — Monthly';
  final course = courseId == null ? null : DemoData.courseById(courseId);
  return course?.title ?? 'Shikhi Pro — Monthly';
}

/// Full price of the item before any coupon.
int itemPrice({String? courseId, String? plan}) {
  if (plan == 'pro') return proMonthlyPrice;
  final course = courseId == null ? null : DemoData.courseById(courseId);
  return course?.price ?? proMonthlyPrice;
}

/// Price after applying [couponCode] via `Coupon.applyTo`.
///
/// WELCOME10 is a flat −৳150 coupon, so this returns exactly `price - 150`;
/// STUDENT20 is −20%.
int discountedTotal({required int price, String? couponCode}) {
  if (couponCode == null || couponCode.isEmpty) return price;
  final coupon = DemoData.couponByCode(couponCode);
  if (coupon == null) return price;
  return coupon.applyTo(price);
}

/// Formats an amount as taka with grouping: 1500 -> '৳1,500'.
String formatTaka(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer('৳');
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// '19 Nov 2026' style label for [when] (defaults to now).
String todayLabel([DateTime? when]) {
  final date = when ?? DateTime.now();
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

/// New invoice number: 'SHK-2026-' + 4 random digits.
String newInvoiceNo() {
  final digits = Random().nextInt(9000) + 1000;
  return 'SHK-2026-$digits';
}

/// Accent color for a payment-method brand dot (theme colors only).
Color methodDotColor(BuildContext context, String method) {
  final cs = context.cs;
  switch (method.toLowerCase()) {
    case 'bkash':
      return cs.danger;
    case 'nagad':
      return cs.warning;
    case 'rocket':
      return cs.info;
    default:
      return cs.teal;
  }
}
