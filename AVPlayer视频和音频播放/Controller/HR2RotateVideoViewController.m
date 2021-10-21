//
//  HR2RotateVideoViewController.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/10/19.
//

#import "HR2RotateVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HRPlayerView.h"
#import "HRFullVideoModel.h"
#import "Masonry.h"

@interface HR2RotateVideoViewController ()
@property (nonatomic, strong) HRPlayerView *playerVedioView;
@property (nonatomic, strong) HRFullVideoModel *model;
@end

@implementation HR2RotateVideoViewController

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
    // Do any additional setup after loading the view.
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    //http://192.168.3.185/音频视频/1.mp4
//    NSString *str = @"http://220.249.115.46:18080/wav/Lovey_Dovey.mp4";
    NSString *str = @"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4";
    
    HRFullVideoModel *model = [[HRFullVideoModel alloc] init];
    model.urlString = str;
    model.isPlay = YES; //由模型控制默认播放还是不播放
    
    self.playerVedioView = [[HRPlayerView alloc] init];
    [self.view addSubview:self.playerVedioView];
    [self.playerVedioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(self.playerVedioView.mas_width).multipliedBy(9.0f/16.0f);
    }];
    
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [self.playerVedioView configViewOrientation:toInterfaceOrientation];
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self.playerVedioView configViewOrientation:toInterfaceOrientation];
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
