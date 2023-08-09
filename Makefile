TARGET := iphone:7.0:2.0
ARCHS := armv6 arm64

ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 1Pal
1Pal_FILES = Tweak.xm SSKeychain.m SSKeychainQuery.m
1Pal_FRAMEWORKS = Security UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = 1PalSettings
1PalSettings_FILES = Preferences.m
1PalSettings_INSTALL_PATH = /Library/PreferenceBundles
1PalSettings_FRAMEWORKS = UIKit
1PalSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/1Pal.plist$(ECHO_END)
after-install::
	install.exec "killall -9 SpringBoard 1Password"
