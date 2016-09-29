LOCAL_PATH := $(call my-dir)

#zlib
include $(LOCAL_PATH)/z.mk

#SSL
include $(LOCAL_PATH)/ssl.mk
  
#Crypto
include $(LOCAL_PATH)/crypto.mk
                    
#cURL
include $(LOCAL_PATH)/curl.mk

#Static zlib
include $(CLEAR_VARS)
LOCAL_MODULE := z
LOCAL_SRC_FILES := $(Z_LOCAL_SRC_FILES)
LOCAL_C_INCLUDES := $(Z_LOCAL_C_INCLUDES)
LOCAL_CPPFLAGS += -std=gnu++0x
include $(LOCAL_PATH)/optimizations.mk
LOCAL_CFLAGS += $(Z_COMMON_CFLAGS)
include $(BUILD_STATIC_LIBRARY)

#Static libssl
include $(CLEAR_VARS)
LOCAL_MODULE := ssl
LOCAL_SRC_FILES := ${Z_LOCAL_SRC_FILES} $(SSL_LOCAL_SRC_FILES)
LOCAL_C_INCLUDES := ${Z_LOCAL_C_INCLUDES} $(SSL_LOCAL_C_INCLUDES)
LOCAL_CPPFLAGS += -std=gnu++0x
include $(LOCAL_PATH)/optimizations.mk
LOCAL_CFLAGS += $(SSL_COMMON_CFLAGS)
include $(BUILD_STATIC_LIBRARY)

#Static libcrypto
include $(CLEAR_VARS)
LOCAL_MODULE := crypto
LOCAL_SRC_FILES := $(CRYPTO_LOCAL_SRC_FILES)
LOCAL_C_INCLUDES := $(CRYPTO_LOCAL_C_INCLUDES)
LOCAL_CPPFLAGS += -std=gnu++0x
include $(LOCAL_PATH)/optimizations.mk
LOCAL_CFLAGS += $(CRYPTO_COMMON_CFLAGS)
include $(BUILD_STATIC_LIBRARY)

#Static libcurl
include $(CLEAR_VARS)
LOCAL_MODULE := curl
LOCAL_SRC_FILES := ${Z_LOCAL_SRC_FILES} $(SSL_LOCAL_SRC_FILES) $(CRYPTO_LOCAL_SRC_FILES) $(CURL_LOCAL_SRC_FILES)
LOCAL_C_INCLUDES := ${Z_LOCAL_C_INCLUDES} $(SSL_LOCAL_C_INCLUDES) $(CRYPTO_LOCAL_C_INCLUDES) $(CURL_LOCAL_C_INCLUDES)
LOCAL_CPPFLAGS += -std=gnu++0x
include $(LOCAL_PATH)/optimizations.mk
LOCAL_CFLAGS += $(CURL_COMMON_CFLAGS)
include $(BUILD_STATIC_LIBRARY)
