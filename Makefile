TARGET = iphone:clang:latest:8.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = kobo
kobo_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
