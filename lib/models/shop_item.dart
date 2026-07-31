import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.water_outlined,
    ),
    ShopItem(
      id: 'theme_emerald',
      nameKey: 'shopThemeEmerald',
      descKey: 'shopThemeEmeraldDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.diamond_outlined,
    ),
    ShopItem(
      id: 'theme_royal',
      nameKey: 'shopThemeRoyal',
      descKey: 'shopThemeRoyalDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.shield_outlined,
    ),
    ShopItem(
      id: 'theme_crimson',
      nameKey: 'shopThemeCrimson',
      descKey: 'shopThemeCrimsonDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.local_fire_department_outlined,
    ),
    ShopItem(
      id: 'bg_vault',
      nameKey: 'shopBgVault',
      descKey: 'shopBgVaultDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.security_outlined,
    ),
    ShopItem(
      id: 'bg_stars',
      nameKey: 'shopBgStars',
      descKey: 'shopBgStarsDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.star_outline,
    ),
    ShopItem(
      id: 'bg_neon',
      nameKey: 'shopBgNeon',
      descKey: 'shopBgNeonDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.bolt_outlined,
    ),
    ShopItem(
      id: 'bg_aurora',
      nameKey: 'shopBgAurora',
      descKey: 'shopBgAuroraDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.gradient_outlined,
    ),
    ShopItem(
      id: 'skin_soft',
      nameKey: 'shopSkinSoft',
      descKey: 'shopSkinSoftDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.circle_outlined,
    ),
    ShopItem(
      id: 'skin_glass',
      nameKey: 'shopSkinGlass',
      descKey: 'shopSkinGlassDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.blur_on_outlined,
    ),
    ShopItem(
      id: 'skin_bold',
      nameKey: 'shopSkinBold',
      descKey: 'shopSkinBoldDesc',
      price: 200,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.border_style_outlined,
    ),
    ShopItem(
      id: 'feat_export',
      nameKey: 'shopFeatExport',
      descKey: 'shopFeatExportDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.file_download_outlined,
    ),
    ShopItem(
      id: 'feat_unlimited_docs',
      nameKey: 'shopFeatUnlimited',
      descKey: 'shopFeatUnlimitedDesc',
      price: 350,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.folder_special_outlined,
    ),
    ShopItem(
      id: 'feat_cloud_backup',
      nameKey: 'shopFeatBackup',
      descKey: 'shopFeatBackupDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.cloud_upload_outlined,
    ),
    ShopItem(
      id: 'feat_expiry_alert',
      nameKey: 'shopFeatExpiry',
      descKey: 'shopFeatExpiryDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.notifications_active_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
