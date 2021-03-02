//
//  ViewController.m
//  BroadcastUploadExtension
//
//  Created by 贺文杰 on 2021/2/18.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>
#import <AVKit/AVKit.h>

@interface ViewController ()<RPScreenRecorderDelegate, RPBroadcastActivityViewControllerDelegate>

@property(nonatomic,strong)AVPlayerViewController* moviePlayer;
@property(nonatomic,strong)NSString* videoPath;
@property(nonatomic,strong)NSString *recordVideoPath;
@property(nonatomic,strong)AVAssetWriter *assetWriter;
@property(nonatomic,strong)AVAssetWriterInput *assetWriterVideoInput;
@property(nonatomic,strong)AVAssetWriterInput *assetWriterAudioInput;
@property(nonatomic,strong)AVAssetWriterInput *assetWriterMICAudioInput;
@property(nonatomic,strong)AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;
//@property(nonatomic,strong)AVCaptureSession *captureSession;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.view addSubview:self.moviePlayer.view];
    
    if (@available(iOS 12.0, *)) {
        RPSystemBroadcastPickerView *picker = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        picker.preferredExtension = @"com.hewenjie.allFunctions.upload";
        [self.view addSubview:picker];
        picker.center = self.view.center;
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(picker.frame), self.view.frame.size.width, 30)];
        label.text = @"点击上方按钮开始录屏";
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100 / 2, CGRectGetMaxY(label.frame), 100, 50);
        btn.backgroundColor = [UIColor cyanColor];
        [btn addTarget:self action:@selector(loadBroadcastActivityViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        UIButton *recoderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        recoderBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100 / 2, CGRectGetMaxY(btn.frame), 100, 50);
        [recoderBtn setTitle:@"开始录屏" forState:UIControlStateNormal];
        [recoderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [recoderBtn addTarget:self action:@selector(StartRecoder) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:recoderBtn];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100 / 2, CGRectGetMaxY(recoderBtn.frame), 100, 50);
        [closeBtn setTitle:@"关闭录屏" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeRecoder) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeBtn];
    } else {
        // Fallback on earlier versions
    }
    

    
}

//查找应用实现Broadcast Setup UI Extension
- (void)loadBroadcastActivityViewController
{
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        if (!error) {
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.view.backgroundColor = [UIColor greenColor];
            [self presentViewController:broadcastActivityViewController animated:YES completion:^{
                            
            }];
        }
    }];
}

#pragma mark -- RPBroadcastActivityViewControllerDelegate
- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error API_AVAILABLE(ios(10.0), tvos(10.0))
{
    NSLog(@"%s", __FUNCTION__);
    if (broadcastController) { //启动录制
        [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
            NSLog(@"error = %@", error);
        }];
    }
    if (broadcastActivityViewController) {
        [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
                    
        }];
    }
}

- (void)initVideoInputWidth:(CGFloat)width height:(CGFloat)height
{
    NSDictionary *compressionProperties =
        @{AVVideoProfileLevelKey         : AVVideoProfileLevelH264HighAutoLevel,
          AVVideoH264EntropyModeKey      : AVVideoH264EntropyModeCABAC,
          AVVideoAverageBitRateKey       : @(1920 * 1080 * 11.4),
          AVVideoMaxKeyFrameIntervalKey  : @60,
          AVVideoAllowFrameReorderingKey : @NO};
    
    NSDictionary *dic = @{AVVideoCompressionPropertiesKey : compressionProperties,
                          AVVideoCodecKey : AVVideoCodecTypeH264,
                          AVVideoWidthKey : [NSNumber numberWithFloat:width],
                          AVVideoHeightKey : [NSNumber numberWithFloat:height]};
    self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:dic];
    self.pixelBufferAdaptor =
    [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.assetWriterVideoInput
                                              sourcePixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],kCVPixelBufferPixelFormatTypeKey,nil]];
    [self.assetWriter addInput:self.assetWriterVideoInput];
    [self.assetWriterVideoInput setMediaTimeScale:60];
    [self.assetWriter setMovieTimeScale:60];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.assetWriterVideoInput.expectsMediaDataInRealTime = true;
    
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
//    [self.captureSession startRunning];

}

- (void)initAudioInputChannels:(int)ch samples:(CGFloat)rate
{
    //音频的一些配置包括音频各种这里为AAC,音频通道、采样率和音频的比特率
    NSDictionary *dic = @{AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                          AVNumberOfChannelsKey : [NSNumber numberWithInt:ch], //音频通道
                          AVSampleRateKey : [NSNumber numberWithFloat:rate], //采样率
                          AVEncoderBitRateKey : [NSNumber numberWithInt:128000] //音频的比特率
    };
    self.assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:dic];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.assetWriterAudioInput.expectsMediaDataInRealTime = true;
    [self.assetWriter addInput:self.assetWriterAudioInput];
}

- (void)initMICAudioInputWithChannels:(int)ch samples:(CGFloat)rate
{
    //音频的一些配置包括音频各种这里为AAC,音频通道、采样率和音频的比特率
    NSDictionary *dic = @{AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                          AVNumberOfChannelsKey : [NSNumber numberWithInt:ch], //音频通道
                          AVSampleRateKey : [NSNumber numberWithFloat:rate], //采样率
                          AVEncoderBitRateKey : [NSNumber numberWithInt:128000] //音频的比特率
    };
    self.assetWriterMICAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:dic];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.assetWriterMICAudioInput.expectsMediaDataInRealTime = true;
    [self.assetWriter addInput:self.assetWriterMICAudioInput];
}

//开始录屏
- (void)StartRecoder
{
    if ([[RPScreenRecorder sharedRecorder] isAvailable] && [self isSystemVersionOk]) { //判断硬件和ios版本是否支持录屏
        NSLog(@"支持ReplayKit录制");
        //这是录屏的类
        RPScreenRecorder* recorder = RPScreenRecorder.sharedRecorder;
        recorder.delegate = self;
        //在此可以设置是否允许麦克风（传YES即是使用麦克风，传NO则不是用麦克风）
        recorder.microphoneEnabled = YES;
        recorder.cameraEnabled = YES;

        //开起录屏功能
//        [recorder startRecordingWithHandler:^(NSError * _Nullable error) {
//            if (error) {
//
//                NSLog(@"========%@",error.description);
//            } else {
//                if (recorder.recording) {
//                    //记录是否开始录屏 系统也有一个再带的检测是否在录屏的方法 (@property (nonatomic, readonly, getter=isRecording) BOOL recording;)
//                    NSLog(@"正在录屏");
//                }
//            }
//        }];
        
//        self.captureSession = [[AVCaptureSession alloc]init];
        //iOS 11新增的录制方法，拿到录制的音视频数据
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        self.recordVideoPath = [cachesPath stringByAppendingPathComponent:@"Replay/Record.mp4"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:self.recordVideoPath];
        NSError *error = nil;
        self.assetWriter = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:&error];
        [self initVideoInputWidth:UIScreen.mainScreen.bounds.size.width height:UIScreen.mainScreen.bounds.size.height];
        [recorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
            NSLog(@"录制过程中 error = %@", error);
            if (!error) {

//                if (CMSampleBufferDataIsReady(sampleBuffer)) {
//
//
//                    if (self.assetWriter.status == AVAssetWriterStatusFailed) {
//                        NSLog(@"AVAssetWriterStatusFailed");
//                        return;
//                    }
//                }
                switch (bufferType) {
                    case RPSampleBufferTypeVideo: //视频缓冲器，得到YUV数据
                        // Handle video sample buffer
                    {
                        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                        static int64_t frameNumber = 0;
                        if (self.assetWriterVideoInput.readyForMoreMediaData) {
                            NSLog(@"正在写入");
                            [self.pixelBufferAdaptor appendPixelBuffer:imageBuffer
                                                  withPresentationTime:CMTimeMake(frameNumber, 25)];
                        }
                        frameNumber++;
                        
                        NSLog(@"已获取的长度%lu",[NSData dataWithContentsOfFile:self.recordVideoPath].length);
                    }
                        break;
                    case RPSampleBufferTypeAudioApp: //处理app音频样本
                        // Handle audio sample buffer for app audio
                    {
                        
                    }
                        break;
                    case RPSampleBufferTypeAudioMic: //处理麦克风音频，mic音频样本
                        // Handle audio sample buffer for mic audio
                    {
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }else{
                
            }
        } completionHandler:^(NSError * _Nullable error) {
            NSLog(@"录制完成 error = %@", error);
        }];
    } else {
        return;
    }
}

- (void)closeRecoder
{
    //停止录制，并进行预览，存储，分享
    //这里获取的是录制停止后编码的mp4
    RPScreenRecorder *recorder = RPScreenRecorder.sharedRecorder;
//    [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
//        if (previewViewController) {
//            [self presentViewController:previewViewController animated:YES completion:^{
//
//            }];
//        }
//        if (error) {
//            //丢弃录制数据
//            [recorder discardRecordingWithHandler:^{
//
//            }];
//        }
//    }];
    
//    [self.captureSession stopRunning];
    //iOS 11新增的停止录制方法
    [recorder stopCaptureWithHandler:^(NSError * _Nullable error) {
        [self.assetWriter finishWritingWithCompletionHandler:^{
            
        }];
        if (error) {
            NSLog(@"%s, error = %@", __FUNCTION__, error);
        }else{
            
        }
        NSData* data = [NSData dataWithContentsOfFile:self.recordVideoPath];
        NSLog(@"获取的总长度%lu",data.length);
    }];
}

//判断对应系统版本是否支持ReplayKit
- (BOOL)isSystemVersionOk {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -- RPScreenRecorderDelegate
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithPreviewViewController:(nullable RPPreviewViewController *)previewViewController error:(nullable NSError *)error API_AVAILABLE(ios(11.0), tvos(11.0), macos(11.0))
{
    
}

- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder
{
    if ([RPScreenRecorder sharedRecorder].available) {
        
    }
}


-(NSString* )videoPath{
    if (!_videoPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath =[paths objectAtIndex:0];
        _videoPath = [documentsPath stringByAppendingPathComponent:@"recored.mp4"];
    }
    return _videoPath;
}

-(AVPlayerViewController *)moviePlayer{

   if (!_moviePlayer) {
       _moviePlayer=[[AVPlayerViewController alloc]init];
       AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:self.videoPath]];
       _moviePlayer.player = [[AVPlayer alloc]initWithPlayerItem:item];
       _moviePlayer.view.frame=CGRectMake(0, 0, self.view.frame.size.width, 200);
       _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
       _moviePlayer.showsPlaybackControls = YES;
   }
    return _moviePlayer;
    
}


@end
