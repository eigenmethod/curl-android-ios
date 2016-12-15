LOCAL_PATH := $(call my-dir)

#cURL prebuilt
#include $(CLEAR_VARS)
#LOCAL_MODULE := curl-prebuilt
#LOCAL_SRC_FILES := \
#  ../curl-prebuilt-with-ssl/android/$(TARGET_ARCH_ABI)/libcurl.a
#include $(PREBUILT_STATIC_LIBRARY)
################################################################################

include $(CLEAR_VARS)

LOCAL_MODULE    := mqttandroid
LOCAL_SRC_FILES := \
	Clients.c \
	Heap.c \
	LinkedList.c \
	Log.c \
	MQTTClient.c \
	MQTTPacket.c \
	MQTTPacketOut.c \
	MQTTPersistence.c \
	MQTTPersistenceDefault.c \
	MQTTProtocolClient.c \
	MQTTProtocolOut.c \
	MQTTVersion.c \
	Messages.c \
	SSLSocket.c \
	Socket.c \
	SocketBuffer.c \
	StackTrace.c \
	Thread.c \
	Tree.c \
	utf-8.c

#LOCAL_STATIC_LIBRARIES := curl-prebuilt
COMMON_CFLAGS := -DANDROID -frtti -fexceptions -O2

ifeq ($(TARGET_ARCH),arm)
  LOCAL_CFLAGS := -mfpu=vfp -mfloat-abi=softfp -fno-short-enums
endif

LOCAL_CFLAGS += $(COMMON_CFLAGS)
LOCAL_LDLIBS := -lz -llog -Wl,-s
LOCAL_CPPFLAGS += -std=gnu++0x
LOCAL_C_INCLUDES += \
  $(NDK_PATH)/platforms/$(TARGET_PLATFORM)/arch-$(TARGET_ARCH)/usr/include \
  $(LOCAL_PATH)/../../../../boost_1_60_0


#include $(BUILD_SHARED_LIBRARY)
include $(BUILD_STATIC_LIBRARY)