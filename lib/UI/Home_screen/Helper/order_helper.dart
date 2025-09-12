import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'dart:convert';

Map<String, dynamic> buildOrderPayload({
  required PostAddToBillingModel postAddToBillingModel,
  String? tableId,
  String? waiterId,
  required String orderStatus,
  required String orderType,
  required String discountAmount,
  required bool isDiscountApplied,
  required String tipAmount,
  required List<Map<String, dynamic>> payments,
}) {
  final now = DateTime.now().toUtc();

  List<Map<String, dynamic>> items = (postAddToBillingModel.items ?? []).map((item) {
    final qty = (item.qty is int)
        ? (item.qty as int)
        : int.tryParse('${item.qty}') ?? 1;

    final unitPrice = (item.basePrice is num)
        ? (item.basePrice as num).toDouble()
        : double.tryParse('${item.basePrice}') ?? 0.0;

    // compute addon total
    double addonsTotal = 0;
    final addonList = (item.selectedAddons ?? []);
    final addonsMapped = addonList.map<Map<String, dynamic>>((addon) {
      final addonPrice = (addon.price is num)
          ? (addon.price as num).toDouble()
          : double.tryParse('${addon.price}') ?? 0.0;
      addonsTotal += addonPrice;
      return {
        "addonId": addon.id,
        "name": addon.name,
        "price": addonPrice,
      };
    }).toList();

    final computedSubtotal = (unitPrice * qty) + addonsTotal;

    final subtotal = (item.subtotal != null &&
        item.subtotal.toString().trim().isNotEmpty)
        ? (item.subtotal is num
        ? (item.subtotal as num).toDouble()
        : double.tryParse('${item.subtotal}') ?? computedSubtotal)
        : computedSubtotal;

    final Map<String, dynamic> mapped = {
      "product": item.id,
      "quantity": qty,
      "unitPrice": unitPrice,
      "subtotal": subtotal,
    };
    if (item.name != null && ('${item.name}').trim().isNotEmpty) {
      mapped["name"] = item.name;
    }
    if (addonsMapped.isNotEmpty) {
      mapped["addons"] = addonsMapped;
    }
    return mapped;
  }).toList();

  // sanitize payments: ensure method is provided
  final cleanedPayments = payments.map((p) {
    final amount = (p["amount"] is num)
        ? (p["amount"] as num).toDouble()
        : double.tryParse('${p["amount"]}') ?? 0.0;
    final balance = (p["balanceAmount"] is num)
        ? (p["balanceAmount"] as num).toDouble()
        : double.tryParse('${p["balanceAmount"]}') ?? 0.0;
    final methodStr = (p["method"] ?? "").toString().trim();
    return {
      "amount": amount,
      "balanceAmount": balance,
      "method": methodStr.isNotEmpty ? methodStr : "CASH",
    };
  }).toList();

  // compute fallback subtotal & total
  final computedSubtotal = items.fold<double>(
      0, (s, it) => s + ((it["subtotal"] ?? 0) as num).toDouble());

  final payload = <String, dynamic>{
    "date": now.toIso8601String(),
    "items": items,
    "payments": cleanedPayments,
    "orderStatus": orderStatus,
    "orderType": orderType,
    "subtotal": (postAddToBillingModel.subtotal is num)
        ? (postAddToBillingModel.subtotal as num).toDouble()
        : computedSubtotal,
    "tableNo": tableId,
    "waiter": waiterId,
    "tax": postAddToBillingModel.totalTax ?? 0,
    "total": (postAddToBillingModel.total is num)
        ? (postAddToBillingModel.total as num).toDouble()
        : computedSubtotal + (postAddToBillingModel.totalTax ?? 0),
    "discountAmount": double.tryParse(discountAmount) ?? 0.0,
    "isDiscountApplied": isDiscountApplied,
    "tipAmount": double.tryParse(tipAmount) ?? 0.0,
  };
  return payload;
}
