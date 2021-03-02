//
//  SampleHandler.m
//  broadcastUpload
//
//  Created by 贺文杰 on 2021/2/18.
//


#import "SampleHandler.h"

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    NSLog(@"开始录屏");
    //通过NSUserDefaults共享数据
//    NSUserDefaults *userShared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.hewenjie.allFunctions"];
//    [userShared setObject:@"数据共享" forKey:@"wjContent"];
//    [userShared synchronize];
}

//将数据从共享的数据区中读取出来
- (NSString *)readTextByFileManager
{
    NSError *err = nil;
    NSURL *containerUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.hewenjie.allFunctions"];
    containerUrl = [containerUrl URLByAppendingPathComponent:@"Library/Caches/recodeUserData"];
    NSString *value = [NSString stringWithContentsOfURL:containerUrl encoding:NSUTF8StringEncoding error:&err];
    return value;
}

//将数据写入文件，并存入共享的数据区
- (BOOL)writeTextByFileManager
{
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.hewenjie.allFunctions"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/recodeUserData"];
    
    NSString *value = @"xie ru shu ju";
    BOOL result = [value writeToURL:containerURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
    return result;
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"暂停录屏");
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"继续录屏");
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"结束录屏");
}

//直播
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    NSLog(@"录屏中...");
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *path = [cachesPath stringByAppendingPathComponent:@"Replay/screenRecord.mp4"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    NSError *error = nil;
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:&error];
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo: //视频缓冲器，得到YUV数据
            // Handle video sample buffer
        {
            
        }
            break;
        case RPSampleBufferTypeAudioApp: //处理app音频样本
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic: //处理麦克风音频，mic音频样本
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

@end
