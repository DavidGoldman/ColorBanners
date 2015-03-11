include theos/makefiles/common.mk

BUNDLE_NAME = ColorBannersPrefs
ColorBannersPrefs_FILES = ColorBannersPrefs.mm ColorBannersCells.m
ColorBannersPrefs_INSTALL_PATH = /Library/PreferenceBundles
ColorBannersPrefs_FRAMEWORKS = UIKit
ColorBannersPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ColorBannersPrefs.plist$(ECHO_END)
