# GNUmakefile for SmallClipboard (Linux/GNUstep)
#
# Clipboard manager: history of copied text, persist with SmallStepLib SSFileSystem,
# app lifecycle and menus via SmallStepLib.
#
# Build SmallStepLib first: cd ../SmallStepLib && make && make install
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallClipboard

SmallClipboard_OBJC_FILES = \
	main.m \
	App/AppDelegate.m \
	Model/ClipboardHistory.m \
	UI/ClipboardWindow.m

SmallClipboard_HEADER_FILES = \
	App/AppDelegate.h \
	Model/ClipboardHistory.h \
	UI/ClipboardWindow.h

SmallClipboard_INCLUDE_DIRS = \
	-I. \
	-IApp \
	-IModel \
	-IUI \
	-I../SmallStepLib/SmallStep/Core \
	-I../SmallStepLib/SmallStep/Platform/Linux

# SmallStep framework (from SmallStepLib)
SMALLSTEP_FRAMEWORK := $(shell find ../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

SmallClipboard_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base
SmallClipboard_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallClipboard_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep
SmallClipboard_TOOL_LIBS = -lSmallStep -lobjc

# About dialog logo (copy from SmallStepLib if missing)
before-all::
	mkdir -p Resources && cp -f ../SmallStepLib/Resources/logo.png Resources/logo.png 2>/dev/null || true
SmallClipboard_RESOURCE_FILES = Resources/logo.png

include $(GNUSTEP_MAKEFILES)/application.make
