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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.moviePlayer.view];
    
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
        
        //iOS 11新增的录制方法，拿到录制的音视频数据
        [recorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
            NSLog(@"录制过程中 error = %@", error);
            if (!error) {
                
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
    
    //iOS 11新增的停止录制方法
    [recorder stopCaptureWithHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s, error = %@", __FUNCTION__, error);
        }
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
