//
//  BroadcastSetupViewController.m
//  broadcastUploadSetupUI
//
//  Created by 贺文杰 on 2021/2/18.
//

#import "BroadcastSetupViewController.h"

@implementation BroadcastSetupViewController

// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    NSLog(@"%s", __FUNCTION__);
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://apple.com/broadcast/streamID"];
    
    // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
    NSDictionary *setupInfo = @{ @"broadcastName" : @"example" };
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    if (@available(iOS 11.0, *)) {
        [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:setupInfo];
    } else {
        // Fallback on earlier versions
    }
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1 userInfo:nil]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

@end
