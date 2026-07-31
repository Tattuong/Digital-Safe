import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../providers/locale_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../privacy_policy_screen.dart';
import '../shop/shop_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();

    final content = [
      AppSectionHeader(AppStrings.t(context, 'security'), icon: Icons.security_outlined),
      AppSettingTile(
        icon: Icons.lock_outline,
        title: AppStrings.t(context, 'changePin'),
        onTap: () => _changePin(context),
      ),
      AppSettingTile(
        icon: Icons.timer_outlined,
        title: AppStrings.t(context, 'autoLock'),
        subtitle: AppStrings.t(context, 'minutes', {'count': '5'}),
        onTap: () {},
      ),
      AppSectionHeader(AppStrings.t(context, 'backup'), icon: Icons.cloud_outlined),
      AppSettingTile(
        icon: Icons.upload_outlined,
        title: AppStrings.t(context, 'backupData'),
        onTap: () => _backup(context),
      ),
      AppSettingTile(
        icon: Icons.download_outlined,
        title: AppStrings.t(context, 'restoreData'),
        onTap: () {},
      ),
      AppSectionHeader(AppStrings.t(context, 'appearance'), icon: Icons.palette_outlined),
      AppSettingTile(
        icon: Icons.dark_mode_outlined,
        title: AppStrings.t(context, 'darkMode'),
        subtitle: theme.isDarkMode ? AppStrings.t(context, 'darkMode') : AppStrings.t(context, 'lightMode'),
        onTap: () => theme.toggleTheme(),
      ),
      AppSettingTile(
        icon: Icons.storefront_outlined,
        title: AppStrings.t(context, 'changeTheme'),
        subtitle: AppStrings.t(context, 'navShop'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen(initialTab: ShopRewardsTab.themes))),
      ),
      AppSectionHeader(AppStrings.t(context, 'language'), icon: Icons.language_outlined),
      AppSettingTile(
        icon: Icons.language_outlined,
        title: AppStrings.t(context, 'language'),
        subtitle: locale.isVietnamese ? 'Tiếng Việt' : 'English',
        onTap: () => _pickLanguage(context, locale),
      ),
      AppSectionHeader(AppStrings.t(context, 'shop'), icon: Icons.stars_rounded),
      AppSettingTile(
        icon: Icons.stars_rounded,
        title: AppStrings.t(context, 'navShop'),
        subtitle: AppStrings.t(context, 'yourCoins', {'count': shop.coins.toString()}),
        iconColor: AppColors.coin,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
      ),
      if (!shop.isBillingDisabled)
        AppSettingTile(
          icon: Icons.shopping_cart_outlined,
          title: AppStrings.t(context, 'buyCoins'),
          onTap: () => CoinPurchaseSheet.show(context),
        ),
      if (shop.isBillingDisabled)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            AppStrings.t(context, 'billingDisabledHint'),
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ),
      AppSettingTile(
        icon: Icons.privacy_tip_outlined,
        title: AppStrings.t(context, 'privacyPolicy'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
      ),
      AppSettingTile(
        icon: Icons.info_outline,
        title: AppStrings.t(context, 'version', {'version': '1.0.1'}),
      ),
      const SizedBox(height: 100),
    ];

    if (embedded) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(child: Text(AppStrings.t(context, 'settings'), style: AppTypography.titleLarge())),
                  CoinBalanceChip(onTap: shop.isBillingDisabled ? null : () => CoinPurchaseSheet.show(context)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(delegate: SliverChildListDelegate(content)),
          ),
        ],
      );
    }

    return AppPageScaffold(
      title: AppStrings.t(context, 'settings'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: shop.isBillingDisabled ? null : () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: content,
    );
  }

  Future<void> _backup(BuildContext context) async {
    final shop = context.read<ShopProvider>();
    final vault = context.read<VaultProvider>();
    if (!shop.hasCloudBackup && !shop.hasExportData) {
      AppToast.show(context, title: AppStrings.t(context, 'exportRequiresPremium'));
      return;
    }
    final data = vault.documents.map((d) => d.toJson()).toList();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    await Share.share(json, subject: 'Digital Safe Backup');
    await shop.rewardForBackup();
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'backupSuccess'));
  }

  Future<void> _changePin(BuildContext context) async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'changePin')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'oldPin')), obscureText: true, keyboardType: TextInputType.number, maxLength: 4),
            TextField(controller: newCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'newPin')), obscureText: true, keyboardType: TextInputType.number, maxLength: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(context, 'save'))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final changed = await AuthService.instance.changePin(oldCtrl.text, newCtrl.text);
      AppToast.show(context, title: changed ? AppStrings.t(context, 'pinChanged') : AppStrings.t(context, 'wrongPin'));
    }
    oldCtrl.dispose();
    newCtrl.dispose();
  }

  Future<void> _pickLanguage(BuildContext context, LocaleProvider locale) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: !locale.isVietnamese ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () { locale.setEnglish(); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('Tiếng Việt'),
              trailing: locale.isVietnamese ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () { locale.setVietnamese(); Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }
}
