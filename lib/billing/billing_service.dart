import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'subscription.dart';

/// Store abstraction. Real builds use [StoreBillingService] (StoreKit 2 /
/// Google Play Billing through the official in_app_purchase plugin, no
/// proprietary SDK). The POC demo and tests use [MockBillingService].
abstract class BillingService {
  Future<bool> purchaseMonthly();
  Future<bool> restore();

  /// Cancellation is handled by the store; this opens its manage screen.
  Future<void> openManageSubscriptions();
}

class MockBillingService implements BillingService {
  MockBillingService({this.succeed = true});
  final bool succeed;
  int purchases = 0;

  @override
  Future<bool> purchaseMonthly() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (succeed) purchases++;
    return succeed;
  }

  @override
  Future<bool> restore() async => purchases > 0;

  @override
  Future<void> openManageSubscriptions() async {}
}

class StoreBillingService implements BillingService {
  StoreBillingService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;
  final InAppPurchase _iap;

  @override
  Future<bool> purchaseMonthly() async {
    if (!await _iap.isAvailable()) return false;
    final res = await _iap.queryProductDetails({Plan.productId});
    if (res.productDetails.isEmpty) return false;
    final done = Completer<bool>();
    late final StreamSubscription<List<PurchaseDetails>> sub;
    sub = _iap.purchaseStream.listen((items) async {
      for (final p in items.where((p) => p.productID == Plan.productId)) {
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);
        if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
          if (!done.isCompleted) done.complete(true);
        } else if (p.status == PurchaseStatus.error || p.status == PurchaseStatus.canceled) {
          if (!done.isCompleted) done.complete(false);
        }
      }
    });
    // Receipt validation happens server-side (App Store Server API / Play
    // Developer API) before the entitlement is granted in production.
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: res.productDetails.first));
    final ok = await done.future.timeout(const Duration(minutes: 5), onTimeout: () => false);
    await sub.cancel();
    return ok;
  }

  @override
  Future<bool> restore() async {
    await _iap.restorePurchases();
    return true;
  }

  @override
  Future<void> openManageSubscriptions() async {
    // iOS: AppStore.showManageSubscriptions(); Android: play.google.com/store/account/subscriptions
  }
}
