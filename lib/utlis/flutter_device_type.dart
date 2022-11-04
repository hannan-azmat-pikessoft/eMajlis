import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as Math;

class Device {
  static double devicePixelRatio = ui.window.devicePixelRatio;
  static ui.Size size = ui.window.physicalSize;
  static double width = size.width;
  static double height = size.height;
  static double screenWidth = width / devicePixelRatio;
  static double screenHeight = height / devicePixelRatio;
  static ui.Size screenSize = new ui.Size(screenWidth, screenHeight);
  final bool isTablet,
      isPhone,
      isIos,
      isAndroid,
      isIphoneX,
      hasNotch,
      isIphone,
      isIphonePlus;
  static Device _device;
  static Function onMetricsChange;
  final double headerHeight;

  Device(
      {this.isTablet,
      this.isPhone,
      this.isIos,
      this.isAndroid,
      this.isIphoneX,
      this.hasNotch,
      this.isIphone,
      this.isIphonePlus,
      this.headerHeight});

  factory Device.get() {
    if (_device != null) return _device;

    if (onMetricsChange == null) {
      onMetricsChange = ui.window.onMetricsChanged;
      ui.window.onMetricsChanged = () {
        _device = null;

        size = ui.window.physicalSize;
        width = size.width;
        height = size.height;
        screenWidth = width / devicePixelRatio;
        screenHeight = height / devicePixelRatio;
        screenSize = new ui.Size(screenWidth, screenHeight);

        onMetricsChange();
      };
    }

    bool isTablet;
    bool isPhone;
    bool isIos = Platform.isIOS;
    bool isAndroid = Platform.isAndroid;
    bool isIphoneX = false;
    bool hasNotch = false;
    bool isIphone = false;
    bool isIphonePlus = false;
    double headerHeight = 0;

    if (devicePixelRatio < 2 && (width >= 1000 || height >= 1000)) {
      isTablet = true;
      isPhone = false;
    } else if (devicePixelRatio == 2 && (width >= 1920 || height >= 1920)) {
      isTablet = true;
      isPhone = false;
    } else {
      isTablet = false;
      isPhone = true;
    }

    // Recalculate for Android Tablet using device inches
    if (isAndroid) {
      final adjustedWidth = _calWidth() / devicePixelRatio;
      final adjustedHeight = _calHeight() / devicePixelRatio;
      final diagonalSizeInches = (Math.sqrt(
              Math.pow(adjustedWidth, 2) + Math.pow(adjustedHeight, 2))) /
          _ppi;
      //print("Dialog size inches is $diagonalSizeInches");
      if (diagonalSizeInches >= 7) {
        isTablet = true;
        isPhone = false;
      } else {
        isTablet = false;
        isPhone = true;
      }
    }

    if (isIos &&
        isPhone &&
        (screenHeight == 812 ||
            screenWidth == 812 ||
            screenHeight == 896 ||
            screenWidth == 896 ||
            // iPhone 12 pro
            screenHeight == 844 ||
            screenWidth == 844 ||
            // Iphone 12 pro max
            screenHeight == 926 ||
            screenWidth == 926)) {
      isIphoneX = true;
      hasNotch = true;
    }

    if (isIos && isPhone && (screenHeight == 667 || screenWidth == 667)) {
      isIphone = true;
    }

    if (isIos && isPhone && (screenHeight == 736 || screenWidth == 736)) {
      isIphonePlus = true;
    }

    if (isIos) {
      if (isIphoneX) {
        // Iphone 11 , Iphone Xr , Iphone Xs Max, Iphone 11 Pro Max
        if ((screenHeight == 896 || screenWidth == 896)) {
          headerHeight = 138.0;
        }
        // Iphone 11 Pro , Iphone X , Iphone Xs
        if ((screenHeight == 812 || screenWidth == 812)) {
          headerHeight = 140.0;
        }

        // Iphone 12 , Iphone 12 Pro , Iphone 12 Pro Max
        if ((screenHeight == 844 ||
            screenWidth == 844 ||
            screenHeight == 926 ||
            screenWidth == 926)) {
          headerHeight = 137.0;
        }
      } else {
        // Iphone 8 667 , Iphone 8 Plus 736 , SE 568
        headerHeight = 76.0;
      }
    } else {
      headerHeight = 80.0;
    }

    if (_hasTopOrBottomPadding()) hasNotch = true;

    return _device = new Device(
        isTablet: isTablet,
        isPhone: isPhone,
        isAndroid: isAndroid,
        isIos: isIos,
        isIphoneX: isIphoneX,
        hasNotch: hasNotch,
        isIphone: isIphone,
        isIphonePlus: isIphonePlus,
        headerHeight: headerHeight);
  }

  static double _calWidth() {
    if (width > height)
      return (width +
          (ui.window.viewPadding.left + ui.window.viewPadding.right) *
              width /
              height);
    return (width + ui.window.viewPadding.left + ui.window.viewPadding.right);
  }

  static double _calHeight() {
    return (height +
        (ui.window.viewPadding.top + ui.window.viewPadding.bottom));
  }

  static int get _ppi => Platform.isAndroid
      ? 160
      : Platform.isIOS
          ? 150
          : 96;

  static bool _hasTopOrBottomPadding() {
    final padding = ui.window.viewPadding;
    //print(padding);
    return padding.top > 0 || padding.bottom > 0;
  }
}
