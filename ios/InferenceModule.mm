#import "InferenceModule.h"
#import <Libtorch-Lite/Libtorch-Lite.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioSettings.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import <React/RCTBridgeModule.h> // Import RCTBridgeModule


@implementation InferenceModule {
    
    @protected torch::jit::mobile::Module _impl;
}
RCT_EXPORT_MODULE();

- (instancetype)init {
    if (self) {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"wav2vec2" ofType:@"ptl"];
        if (!modelPath) {
            NSLog(@"Model file not found!");
            return nil;
        }
        try {
            auto qengines = at::globalContext().supportedQEngines();
            if (std::find(qengines.begin(), qengines.end(), at::QEngine::QNNPACK) != qengines.end()) {
                at::globalContext().setQEngine(at::QEngine::QNNPACK);
            }
            _impl = torch::jit::_load_for_mobile(modelPath.UTF8String);
        }
        catch (const std::exception& exception) {
            NSLog(@"%s", exception.what());
            return nil;
        }
    }
    return self;
}

- (NSString*)recognize:(void*)wavBuffer bufLength:(int)bufLength{
    try {
        at::Tensor tensorInputs = torch::from_blob((void*)wavBuffer, {1, bufLength}, torch::kFloat);
        
        float* floatInput = tensorInputs.data_ptr<float>();
        if (!floatInput) {
            return nil;
        }
        NSMutableArray* inputs = [[NSMutableArray alloc] init];
        for (int i = 0; i < bufLength; i++) {
            [inputs addObject:@(floatInput[i])];
        }
        
        c10::InferenceMode guard;
        
        CFTimeInterval startTime = CACurrentMediaTime();
      auto result = _impl.forward({tensorInputs}).toStringRef();
        CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
        NSLog(@"inference time:%f", elapsedTime);
            
        return [NSString stringWithCString:result.c_str() encoding:[NSString defaultCStringEncoding]];
    }
    catch (const std::exception& exception) {
        NSLog(@"%s", exception.what());
    }
    return nil;
}

RCT_EXPORT_METHOD(recognizeFromFilePath:(NSString *)filePath
                  durationInSeconds:(double)duration
                          callback:(RCTResponseSenderBlock)callback) {
  NSURL *url = [NSURL fileURLWithPath:filePath];
  NSError *error = nil;
  AVAudioFile *file = [[AVAudioFile alloc] initForReading:url error:&error];
  
  if (error) {
      callback(@[[NSString stringWithFormat:@"Error reading audio file: %@", [error localizedDescription]], [NSNull null]]);
      return;
  }
  
  AVAudioFormat *format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32 sampleRate:file.fileFormat.sampleRate channels:1 interleaved:NO];
  
  AVAudioPCMBuffer *buf = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:(AVAudioFrameCount)file.length];
  error = nil;
  [file readIntoBuffer:buf error:&error];
  
  if (error) {
      callback(@[[NSString stringWithFormat:@"Error reading into buffer: %@", [error localizedDescription]], [NSNull null]]);
      return;
  }
  
  float *floatArray = buf.floatChannelData[0];
  NSUInteger floatArrayLength = buf.frameLength;
  
  NSString *result = [self recognize:floatArray bufLength:floatArrayLength];
  
  if (result) {
      callback(@[[NSNull null], result]);
  } else {
      callback(@[@"Error recognizing audio", [NSNull null]]);
  }
}

@end
