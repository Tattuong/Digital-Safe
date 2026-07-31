import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/iap_constants.dart';
import '../providers/shop_provider.dart';
import '../screens/shop/shop_screen.dart';
import 'app_ui.dart';
import 'coin_purchase_sheet.dart';

/// Promo block — use [compact] on Home, full layout in Shop.
class CoinPromoBanner extends StatefulWidget {
  final bool compact;

  const CoinPromoBanner({super.key, this.compact = false});

  @override
  State<CoinPromoBanner> createState() => _CoinPromoBannerState();
}

class _CoinPromoBannerState extends State<CoinPromoBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.compact) return _CompactPromoBanner(expanded: _expanded, onToggle: () => setState(() => _expanded = !_expanded));
    return _FullPromoBanner();
  }
}

class _CompactPromoBanner extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _CompactPromoBanner({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hotCoins = shop.effectiveCoinsForPackIndex(shop.weeklyHotDealPackIndex);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A2744), const Color(0xFF252040)]
                    : [const Color(0xFFEFF6FF), const Color(0xFFFFF7ED)],
              ),
              border: Border.all(color: AppColors.coin.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.coin, AppColors.coin.withValues(alpha: 0.7)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t(context, 'promoCompactTitle'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelBold(size: 13, color: isDark ? Colors.white : AppColors.onSurface),
                            ),
                            Text(
                              AppStrings.t(context, 'promoHotDealDesc', {
                                'pack': shop.weeklyHotDealPackNumber.toString(),
                                'coins': hotCoins.toString(),
                              }),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      if (shop.firstPurchaseBonusAvailable)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppStrings.t(context, 'firstPurchaseBadge'),
                              style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      if (!shop.isBillingDisabled)
                        Material(
                          color: AppColors.coin,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => CoinPurchaseSheet.show(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              child: Text(
                                AppStrings.t(context, 'promoBuyShort'),
                                style: const TextStyle(color: AppColors.trueBlack, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.coin, size: 20),
                    ],
                  ),
                ),
                if (expanded) ...[
                  Divider(height: 1, color: AppColors.coin.withValues(alpha: 0.15)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: _UnlockProgress(shop: shop, dense: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
                            icon: const Icon(Icons.storefront_outlined, size: 16),
                            label: Text(AppStrings.t(context, 'navShop'), style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullPromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hotCoins = shop.effectiveCoinsForPackIndex(shop.weeklyHotDealPackIndex);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A2744), const Color(0xFF2A1F4E)]
                : [const Color(0xFFEFF6FF), const Color(0xFFFFF7ED)],
          ),
          border: Border.all(color: AppColors.coin.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coin.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: AppColors.coin, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.t(context, 'promoHotDeal'),
                        style: const TextStyle(color: AppColors.coin, fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (shop.firstPurchaseBonusAvailable) ...[
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.t(context, 'firstPurchaseBadge'),
                    style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.t(context, 'promoHotDealDesc', {
                'pack': shop.weeklyHotDealPackNumber.toString(),
                'coins': hotCoins.toString(),
              }),
              style: TextStyle(color: isDark ? Colors.white : AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            _UnlockProgress(shop: shop),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!shop.isBillingDisabled)
                  Expanded(
                    child: FilledButton(
                      onPressed: () => CoinPurchaseSheet.show(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.coin,
                        foregroundColor: AppColors.trueBlack,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(AppStrings.t(context, 'promoBuyNow'), style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                if (!shop.isBillingDisabled) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
                    child: Text(AppStrings.t(context, 'navShop'), style: const TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockProgress extends StatelessWidget {
  final ShopProvider shop;
  final bool dense;

  const _UnlockProgress({required this.shop, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final next = shop.nextUnlockItem;
    if (next == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(top: dense ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t(context, 'promoUnlockRemaining', {'count': shop.coinsToNextUnlock.toString()}),
            style: TextStyle(
              color: isDark ? Colors.white54 : AppColors.onSurfaceVariant,
              fontSize: dense ? 10 : 11,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: shop.unlockProgress,
              minHeight: dense ? 5 : 7,
              backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
              color: AppColors.coin,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact promo header inside the coin purchase bottom sheet.
class CoinPurchasePromoHeader extends StatelessWidget {
  const CoinPurchasePromoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final hotIndex = shop.weeklyHotDealPackIndex;
    final total = shop.effectiveCoinsForPackIndex(hotIndex);
    final bonus = total - IapConstants.coinPackAmounts[hotIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.coin.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.coin.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: AppColors.coin, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.t(context, 'purchasePromoDesc', {
                'pack': shop.weeklyHotDealPackNumber.toString(),
                'coins': total.toString(),
                'bonus': bonus.toString(),
              }),
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ),
          if (shop.firstPurchaseBonusAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                AppStrings.t(context, 'firstPurchaseBadge'),
                style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 9, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
