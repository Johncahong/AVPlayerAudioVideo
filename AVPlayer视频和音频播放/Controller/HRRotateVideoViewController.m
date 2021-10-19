//
//  HRRotateVideoViewController.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import "HRRotateVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HRPlayerVideoView.h"
#import "HRFullVideoModel.h"

@interface HRRotateVideoViewController ()

@property (weak, nonatomic) IBOutlet HRPlayerVideoView *playerVedioView;
@property (nonatomic, strong) HRFullVideoModel *model;
@end

@implementation HRRotateVideoViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //必须设置，否则扬声器默认跟随系统声音模式
    //能播放能录音，该模式下声音默认出口是听筒（戴耳机才有声音），切换到扬声器通过以下方式
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    //http://192.168.3.185/音频视频/1.mp4
    NSString *str = @"http://220.249.115.46:18080/wav/Lovey_Dovey.mp4";
//    NSString *str = @"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4";
    
    HRFullVideoModel *model = [[HRFullVideoModel alloc] init];
    model.urlString = str;
    model.isPlay = YES; //由模型控制默认播放还是不播放
    [self.playerVedioView setModel:model addController:self];
    self.model = model;
    
    if (model.isPlay) {
        [self.playerVedioView play];
    }
    
    //监听进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //监听进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - 通知
-(void)enterForeground:(NSNotification *)notification{
    NSLog(@"enterForeground");
    if (self.model.isPlay == YES) {
        [self.playerVedioView play];
    }
}

-(void)enterBackground:(NSNotification *)notification{
    NSLog(@"enterBackground");
    if (self.model.isPlay == YES) {
        [self.playerVedioView pause];
    }
}

// 状态栏的样式
/* 导航栏控制器会拦截它rootViewController的preferredStatusBarStyle，
   所以必须导航栏控制器的preferredStatusBarStyle
*/
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden{
    return self.statusHidden;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}
@end
