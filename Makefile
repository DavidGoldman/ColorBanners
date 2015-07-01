export ARCHS = armv7 arm64
export TARGET = iphone:8.2:8.2
include theos/makefiles/common.mk

TWEAK_NAME = ColorBanners
ColorBanners_FILES = Tweak.xm CBRGradientView.m UIColor+ColorBanners.m CBRPrefsManager.m CBRAppList.m CBRColorCache.m CBRReadabilityManager.m private/*.m
ColorBanners_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += colorbannersprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
