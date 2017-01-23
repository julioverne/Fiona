include theos/makefiles/common.mk

TWEAK_NAME = Fiona
Fiona_FILES = Fiona.xm
Fiona_FRAMEWORKS = CydiaSubstrate Foundation UIKit

Fiona_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
Fiona_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk

	
all::
	@echo "[+] Copying Files..."
	@cp ./obj/obj/debug/Fiona.dylib //Library/MobileSubstrate/DynamicLibraries/Fiona.dylib
	@/usr/bin/ldid -S //Library/MobileSubstrate/DynamicLibraries/Fiona.dylib
	@echo "DONE"
	#@killall SpringBoard
	