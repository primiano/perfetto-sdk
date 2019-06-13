# Perfetto Client API SDK (Experimental)

This repo contains the experimental Perfetto SDK.

The perfetto SDK consists of:
- The amalgamated perfetto client library [perfetto.cc](perfetto.cc) and 
  [perfetto.h](perfetto.h).
- A source file with usage example [example.cc](example.cc) 
- The Google protobuf library [third_party/protobuf](third_party/protobuf).
  This dependency will likely go away in next releases.


**The SDK is currently experimental and subjected to changes!**

See also:
[Perefetto public API surface](https://android.googlesource.com/platform/external/perfetto/+/refs/heads/master/include/README.md)

>  The amalgamated source has been generated via
>  `tools/gen_amalgamated --gn_args 'target_os="android" target_cpu="arm64" is_debug=false'` 
>
>  Perfetto revision: https://android.googlesource.com/platform/external/perfetto/+/6b5210e9dfb6bbf58d62d0010e3369e95cd13085

# Usage:

## 1. Install the NDK:
Linux:  https://dl.google.com/android/repository/android-ndk-r17b-linux-x86_64.zip

Mac: https://dl.google.com/android/repository/android-ndk-r17b-darwin-x86_64.zip

Unzip it and
```
export NDK_HOME=path/to/unzipped/ndk
```

## 2. Build the example
```
make -j
```

## 3. Run it on an Android device
```
make test
```
