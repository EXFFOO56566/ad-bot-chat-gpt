import 'dart:io';

class UnitIdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // ignore: deprecated_member_use
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // ignore: deprecated_member_use
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }


  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // ignore: deprecated_member_use
      // return 'ca-app-pub-3940256099942544/6300978111';
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // ignore: deprecated_member_use
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
