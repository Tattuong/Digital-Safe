# Digital Safe ⭐⭐⭐⭐⭐

**Kho lưu trữ cá nhân** — ứng dụng két sắt số an toàn cho tài liệu cá nhân.

## Tính năng

- Lưu trữ: CCCD, Passport, GPLX, Bằng cấp, Chứng chỉ, Bảo hiểm, Wifi Password, License Key
- Bảo mật: PIN 4 số, mã hóa AES-256
- Cửa hàng: mua điểm, theme, skin, hình nền, tính năng premium
- IAP Google Billing: 10 gói `ds_pack_1` … `ds_pack_10` + `ds_remove_ads`
- Remote config: https://api2.blwsmartware.net/N219.json

## Application ID

`com.digitalsafemng.digitalsafe`

## Build

```bash
flutter pub get
python3 tool/generate_logo.py
flutter pub run flutter_launcher_icons
flutter build appbundle --release
```

## Google Play checklist

1. Tạo app mới với package `com.digitalsafemng.digitalsafe`
2. Upload icon 512×512 từ `assets/logo.png`
3. Tạo 11 IAP products theo `iap_config/GOOGLE_PLAY_PRODUCTS.md`
4. Điền Privacy Policy URL
5. Ký release với `key.properties`
