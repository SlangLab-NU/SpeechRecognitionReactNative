#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h> // Import RCTBridgeModule

NS_ASSUME_NONNULL_BEGIN

@interface InferenceModule : NSObject <RCTBridgeModule> // Adopt the RCTBridgeModule protocol

- (instancetype)init;

// Modify the recognize method to accept a data type that can be passed from JavaScript.
// For example, if you're reading audio data from a file, you can pass the file path as a string.
- (void)recognizeFromFilePath:(NSString *)filePath
             durationInSeconds:(double)duration
                     callback:(RCTResponseSenderBlock)callback NS_SWIFT_NAME(recognizeFromFilePath(_:durationInSeconds:callback:));


@end

NS_ASSUME_NONNULL_END
