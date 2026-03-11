#
# SmallClipboard unit tests
# Build from SmallClipboard: make -f Tests/GNUmakefile
# Run: ./Tests/obj/test_SmallClipboard
#

include $(GNUSTEP_MAKEFILES)/common.make

SMALLSTEP_FRAMEWORK := $(shell find ../../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

TOOL_NAME = test_SmallClipboard
test_SmallClipboard_OBJC_FILES = \
	SmallClipboardTests.m \
	../App/AppDelegate.m \
	../Model/ClipboardHistory.m \
	../UI/ClipboardWindow.m

test_SmallClipboard_INCLUDE_DIRS = -I.. -I../Model -I../App -I../UI
test_SmallClipboard_INCLUDE_DIRS += -I../../SmallStepLib/SmallStep/Core -I../../SmallStepLib/SmallStep/Platform/Linux
test_SmallClipboard_INCLUDE_DIRS += -I../../SmallStepLib/Tests
test_SmallClipboard_TOOL_LIBS = -lSmallStep -lgnustep-gui -lgnustep-base -lobjc
test_SmallClipboard_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined

before-all::
	$(MAKE) -C ../../SmallStepLib

include $(GNUSTEP_MAKEFILES)/tool.make
