# Copyright (C) 2019 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

NDK_HOME ?= $(HOME)/code/perfetto/buildtools/ndk
TARGET ?= android

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
NDK_HOST := darwin-x86_64
else
NDK_HOST := linux-x86_64
endif

ifeq ($(TARGET),android)
CXX := $(NDK_HOME)/toolchains/llvm/prebuilt/$(NDK_HOST)/bin/clang++
else
CXX := clang++
endif

LNK := $(CXX)

TEST_CFG = duration_ms: 10000; buffers { size_kb: 1024 }; data_sources { config { name: "com.example.mytrace" } }

CFLAGS += -std=c++11
CFLAGS += -fno-omit-frame-pointer
CFLAGS += -g
CFLAGS += -Wa,--noexecstack
CFLAGS += -fPIC
CFLAGS += -fno-exceptions
CFLAGS += -fno-rtti
CFLAGS += -fvisibility=hidden
CFLAGS += -Wno-everything
CFLAGS += -I.
CFLAGS += -DPERFETTO_BUILD_WITH_EMBEDDER
CFLAGS += -DPERFETTO_IMPLEMENTATION
CFLAGS += -DHAVE_PTHREAD=1

ANDROID_CFLAGS += --target=aarch64-linux-android
ANDROID_CFLAGS += --sysroot=$(NDK_HOME)/sysroot/usr/include
ANDROID_CFLAGS += -I$(NDK_HOME)/sources/android/support/include
ANDROID_CFLAGS += -I$(NDK_HOME)/sources/cxx-stl/llvm-libc++/include
ANDROID_CFLAGS += -I$(NDK_HOME)/sources/cxx-stl/llvm-libc++abi/include
ANDROID_CFLAGS += -isystem$(NDK_HOME)/sysroot/usr/include
ANDROID_CFLAGS += -isystem$(NDK_HOME)/sysroot/usr/include/aarch64-linux-android
ANDROID_CFLAGS += -DANDROID
ANDROID_CFLAGS += -D__ANDROID_API__=21
ifeq ($(TARGET),android)
CFLAGS += $(ANDROID_CFLAGS)
endif

ANDROID_LDFLAGS += -gcc-toolchain $(NDK_HOME)/toolchains/aarch64-linux-android-4.9/prebuilt/$(NDK_HOST)
ANDROID_LDFLAGS += --sysroot=$(NDK_HOME)/platforms/android-21/arch-arm64
ANDROID_LDFLAGS += --target=aarch64-linux-android
ANDROID_LDFLAGS += -Wl,--exclude-libs,libunwind.a
ANDROID_LDFLAGS += -Wl,--exclude-libs,libgcc.a
ANDROID_LDFLAGS += -Wl,--exclude-libs,libc++_static.a
ANDROID_LDFLAGS += -fuse-ld=gold
ANDROID_LDFLAGS += -Wl,--no-undefined
ANDROID_LDFLAGS += -Wl,-z,noexecstack
ANDROID_LDFLAGS += -Wl,-z,now
ANDROID_LDFLAGS += -Wl,--fatal-warnings
ANDROID_LDFLAGS += -pie
ANDROID_LDFLAGS += -L$(NDK_HOME)/sources/cxx-stl/llvm-libc++/libs/arm64-v8a
ANDROID_LDFLAGS += -lgcc -lc++_static -lc++abi -llog
ifeq ($(TARGET),android)
LDFLAGS += $(ANDROID_LDFLAGS)
endif

all: out/example

clean:
	rm -rf out

out/check_ndk.stamp:
	@test -f $(NDK_HOME)/sysroot/repo.prop || echo Cannot find NDK in $(NDK_HOME)
	@touch $@

out/mkdir.stamp:
	@mkdir -p out
	@touch $@

# Build object files
out/%.o: %.cc out/mkdir.stamp out/check_ndk.stamp Makefile
	@echo CXX $@
	@$(CXX) -o $@ -c $(CFLAGS) $<

# Link executable
out/example: out/perfetto.o out/example.o
	@echo LNK $@
	@$(LNK) $^ $(LDFLAGS) -o $@

test: out/example
	adb root
	adb push $< /data/local/tmp
	echo '$(TEST_CFG)' | adb shell perfetto --txt -c - -o /data/misc/perfetto-traces/trace --background
	adb shell /data/local/tmp/example


.PHONY: clean all
