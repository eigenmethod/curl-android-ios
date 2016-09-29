Z_COMMON_CFLAGS := \
  -DHAVE_HIDDEN
Z_CSOURCES := \
  adler32.c crc32.c deflate.c infback.c inffast.c inflate.c inftrees.c trees.c zutil.c \
  compress.c uncompr.c gzclose.c gzlib.c gzread.c gzwrite.c
Z_LOCAL_SRC_FILES := $(addprefix ../../zlib/,$(Z_CSOURCES))
Z_LOCAL_C_INCLUDES := \
  $(LOCAL_PATH)/../../zlib \
  $(NDK_PATH)/platforms/$(TARGET_PLATFORM)/arch-arm/usr/include