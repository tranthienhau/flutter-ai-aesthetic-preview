/// Pure subscription rules: 3-day free trial, then a monthly auto-renewing plan.
/// No Flutter imports so the billing flow is unit-tested without a device.
library;

enum SubStatus { none, trial, active, cancelled, expired }

class Plan {
  static const productId = 'mirra_monthly';
  static const priceLabel = '79 ILS';
  static const trialDays = 3;
  static const periodDays = 30;
  static const fillerPreviewsPerMonth = 30;
}

class Subscription {
  const Subscription({
    this.status = SubStatus.none,
    this.trialEndsAt,
    this.periodEndsAt,
    this.autoRenew = false,
    this.fillerUsed = 0,
  });

  final SubStatus status;
  final DateTime? trialEndsAt;
  final DateTime? periodEndsAt;
  final bool autoRenew;
  final int fillerUsed;

  Subscription copyWith({
    SubStatus? status,
    DateTime? trialEndsAt,
    DateTime? periodEndsAt,
    bool? autoRenew,
    int? fillerUsed,
  }) =>
      Subscription(
        status: status ?? this.status,
        trialEndsAt: trialEndsAt ?? this.trialEndsAt,
        periodEndsAt: periodEndsAt ?? this.periodEndsAt,
        autoRenew: autoRenew ?? this.autoRenew,
        fillerUsed: fillerUsed ?? this.fillerUsed,
      );

  /// Sign up starts the trial. A second trial is never granted.
  Subscription startTrial(DateTime now) {
    if (status != SubStatus.none) return this;
    return copyWith(status: SubStatus.trial, trialEndsAt: now.add(const Duration(days: Plan.trialDays)));
  }

  /// Purchase during or after the trial. Billing starts when the trial ends,
  /// so a user who subscribes on day 1 is not charged for the remaining trial days.
  Subscription purchase(DateTime now) {
    final start = (trialEndsAt != null && now.isBefore(trialEndsAt!)) ? trialEndsAt! : now;
    return copyWith(
      status: SubStatus.active,
      periodEndsAt: start.add(const Duration(days: Plan.periodDays)),
      autoRenew: true,
      fillerUsed: 0,
    );
  }

  /// Cancel keeps access until the paid period ends; no further charges.
  Subscription cancel() {
    if (status != SubStatus.active) return this;
    return copyWith(status: SubStatus.cancelled, autoRenew: false);
  }

  /// Advance the clock: trial expiry, renewal, or end of a cancelled period.
  Subscription tick(DateTime now) {
    switch (status) {
      case SubStatus.trial:
        return now.isBefore(trialEndsAt!) ? this : copyWith(status: SubStatus.expired);
      case SubStatus.active:
        if (now.isBefore(periodEndsAt!)) return this;
        var end = periodEndsAt!;
        while (!now.isBefore(end)) {
          end = end.add(const Duration(days: Plan.periodDays));
        }
        return copyWith(periodEndsAt: end, fillerUsed: 0);
      case SubStatus.cancelled:
        return now.isBefore(periodEndsAt!) ? this : copyWith(status: SubStatus.expired);
      case SubStatus.none:
      case SubStatus.expired:
        return this;
    }
  }

  bool hasAccess(DateTime now) {
    final s = tick(now);
    return s.status == SubStatus.trial || s.status == SubStatus.active || s.status == SubStatus.cancelled;
  }

  bool get showPaywall => status == SubStatus.expired || status == SubStatus.none;

  int trialDaysLeft(DateTime now) {
    if (status != SubStatus.trial) return 0;
    final h = trialEndsAt!.difference(now).inHours;
    return h <= 0 ? 0 : (h / 24).ceil();
  }

  bool canGenerateFiller(DateTime now) =>
      hasAccess(now) && (status == SubStatus.trial || fillerUsed < Plan.fillerPreviewsPerMonth);

  Subscription useFiller() => copyWith(fillerUsed: fillerUsed + 1);
}
