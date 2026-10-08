import 'package:digital_safe/core/constants/ad_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('banner stays off until real AdMob app and banner units are pasted', () {
    expect(AdConstants.androidAppId, isEmpty);
    expect(AdConstants.iosAppId, isEmpty);
    expect(AdConstants.androidBannerId, isEmpty);
    expect(AdConstants.iosBannerId, isEmpty);
    expect(AdConstants.isConfigured, isFalse);
    expect(AdConstants.bannerHeight, 50);
  });
}
