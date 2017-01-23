include theos/makefiles/common.mk

BUNDLE_NAME = FionaSettings
FionaSettings_FILES = FionaSettingsController.mm
FionaSettings_INSTALL_PATH = /Library/PreferenceBundles
FionaSettings_FRAMEWORKS = UIKit QuartzCore CoreGraphics MessageUI Social Twitter
FionaSettings_PRIVATE_FRAMEWORKS = Preferences
FionaSettings_CFLAGS = -fobjc-arc

FionaSettings_LDFLAGS = -Wl,-segalign,4000

FionaSettings_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/bundle.mk

all::
	@echo "[+] Copying Files..."
	@cp ./obj/FionaSettings.bundle/FionaSettings //Library/PreferenceBundles/FionaSettings.bundle/FionaSettings
	@ldid -S //Library/PreferenceBundles/FionaSettings.bundle/FionaSettings
	@echo "DONE"
	
	