# This file document some technical procedures.

### 1. Compiling latest pytorch libraries from source [official doc](https://pytorch.org/mobile/ios/)

To track the latest updates for iOS, you can build the PyTorch iOS libraries from the source code.
```
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
# if you are updating an existing checkout
git submodule sync
git submodule update --init --recursive
```
#### Build LibTorch-Lite for iOS Simulators
Open terminal and navigate to the PyTorch root directory. Run the following command (if you already build LibTorch-Lite for iOS devices (see below), run rm -rf build_ios first):
```
UILD_PYTORCH_MOBILE=1 IOS_PLATFORM=SIMULATOR ./scripts/build_ios.sh
```
#### Build LibTorch-Lite for arm64 Devices
```
BUILD_PYTORCH_MOBILE=1 IOS_ARCH=arm64 ./scripts/build_ios.sh
```

### 2. Native Module and React Native
React Native can import the class you have in native languages like Objective-C and Swift. Note if you use Swift to implement the native modules, you need to create a wrapper Objective-C for that as RN does not talk directly with swift.
``` typescript
// Import native modules
import { NativeModules } from 'react-native';
// Import native class you created
const { InferenceModule } = NativeModules;
// Use method you created in class
InferenceModule.recognizeFromFilePath(audioFilePath)
```
On the Objective-C part, you need to import RCTBridge Library in your header file and make it extends RCTBridgeModule
```objc
#import <React/RCTBridgeModule.h>
// Also make your class extends RCTBridgeModule
@interface InferenceModule : NSObject <RCTBridgeModule>
```
In your .mm implementation, you need:
```objc
#import "InferenceModule.h"
#import <React/RCTBridgeModule.h> // Import RCTBridgeModule
@implementation InferenceModule {
    
}
RCT_EXPORT_MODULE(); // Call method to export your methods.

//Also add macro to methods that you need to export.
RCT_EXPORT_METHOD(recognizeFromFilePath:(NSString *)filePath){
    ...
}
```