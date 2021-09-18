//
//  HRPlayerVideoView.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import "HRPlayerVideoView.h"

@interface HRPlayerVideoView ()

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic,weak)UIViewController *controller;
@property (assign,nonatomic)double currentTime; //当前时间;

@property (nonatomic, assign) BOOL isUpdateSeek;//是否查找定位到指定帧
@property (nonatomic, strong) id timeObserve;
@property (nonatomic, assign) BOOL isHandleViewHidden;//可操作的子控件是否隐藏
@end

@implementation HRPlayerVideoView

+(Class)layerClass{
    return [AVPlayerLayer class];
}

-(void)setPlayer:(AVPlayer *)player{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    playerLayer.player = player;
}

-(AVPlayer *)player{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    return playerLayer.player;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    NSLog(@"kk awakeFromNib");
    
    _progressSlider.value = 0;
    _isUpdateSeek = YES;
    _bottomBgView.alpha = 0.0;
    
    self.player = [AVPlayer playerWithPlayerItem:nil];
}

-(void)setModel:(HRFullVideoModel *)model addController:(UIViewController *)controller{
    _model = model;
    //这里控制器属性必须弱引用，否则会造成循环引用，导致dealloc永远不执行
    self.controller = controller;
    
    [self.player replaceCurrentItemWithPlayerItem:model.playerItem];
    
    [self addUpProgress];
    
    self.bottomBgView.userInteractionEnabled = !model.isPlay;
    
    //默认隐藏
    self.isHandleViewHidden = model.isPlay;
    [self oneTapAction];
}

-(void)addUpProgress{
    /*
     addPeriodicTimeObserverForInterval：监听播放进度。
     Interval参数表示回调的间隔时间
     CMTimeMake(1, 10)：1表示当前第1帧，10表示每秒有10帧。这里表示每1/10=0.1秒回调一次block
     该方法返回一个观察者，销毁时需要主动移除观察者：[player removeTimeObserver:timeObserve]
     */
    __weak typeof(self) wself = self;
    NSLog(@"11%@", self);
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(40, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if (wself.player.currentItem.duration.timescale>0 && wself.bottomBgView.userInteractionEnabled==NO) {
            wself.bottomBgView.userInteractionEnabled = YES;
        }
        
        //视频总时长（单位秒）
        float total = wself.player.currentItem.duration.value/ wself.player.currentItem.duration.timescale;
        //当前播放时长（单位秒）
        float current = wself.player.currentItem.currentTime.value / wself.player.currentTime.timescale;
        
        if (wself.isUpdateSeek == YES) {
            wself.progressSlider.value = current / total;
        }
        wself.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d", (int)current/60, (int)current%60, (int)total/60, (int)total%60];
        NSLog(@"%f",wself.progressSlider.value);
    }];
}

#pragma mark - 对外的方法
-(void)play{
    [self.player play];
    self.isPlay = YES;
    self.playButton.selected = YES;
}
-(void)pause{
    [self.player pause];
    self.isPlay = NO;
}

- (IBAction)progressSliderChange:(UISlider *)sender forEvent:(UIEvent *)event {
    /*CMTimeMake(value, timeScale)的含义
      value表示当前第value帧，timeScale表示每秒timeScale帧，value/timeScale的值表示当前已播放时长（秒数）
     */
    UITouch*touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseBegan:
        {
            NSLog(@"开始拖动");
            self.isUpdateSeek = NO;
        }
            break;
        case UITouchPhaseMoved:
        {
            NSLog(@"拖动ing");
            self.isUpdateSeek = NO;
        }
            break;
        case UITouchPhaseEnded:
        {
            NSLog(@"结束拖动");
            self.isUpdateSeek = NO;
            
            CMTime goalTime = CMTimeMake(_progressSlider.value * self.player.currentItem.duration.value, self.player.currentItem.duration.timescale);
            __weak typeof(self) wself = self;
            //调用seekToTime方法后，需要等零点几秒才会定位到指定帧，定位成功（画面刷新）有个block回调
            [self.player seekToTime:goalTime toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL finished) {
                if (finished) {
                    wself.isUpdateSeek = YES;
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (IBAction)playClick:(UIButton *)sender {
    [self touchPlayOrStop];
}

-(void)touchPlayOrStop{
    if (_isPlay) {
        _isPlay = NO;
        [self.player pause];
        self.playButton.selected = NO;
    }else{
        _isPlay = YES;
        [self.player play];
        self.playButton.selected = YES;
    }
    _model.isPlay = _isPlay;
}

//全屏
- (IBAction)fullScreenBtnClick:(UIButton *)sender {
    [self turnOrientation:UIInterfaceOrientationLandscapeRight];
}

//竖屏
- (IBAction)turnScreenPortrait:(UIButton *)sender {
    if (UIDevice.currentDevice.orientation != UIInterfaceOrientationPortrait) {
        [self turnOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self.controller.navigationController popViewControllerAnimated:YES];
    }
}

-(void)turnOrientation:(UIInterfaceOrientation)orientaion{
    switch (orientaion) {
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
        {
            self.controller.navigationController.navigationBar.hidden = YES;
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            self.controller.navigationController.navigationBar.hidden = NO;
        }
            break;
        default:
            break;
    }
    NSNumber *number = [NSNumber numberWithInt:(int)orientaion];
    [[UIDevice currentDevice] setValue:number forKey:@"Orientation"];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //将像素point由point所在视图转换到目标视图view中，返回在目标视图view中的像素值
    CGPoint p = [self convertPoint:point toView:self.bottomBgView];
    if (![self.bottomBgView pointInside:p withEvent:event]) {
        
        double nowTime = CACurrentMediaTime();
        double difference = nowTime - self.currentTime;
        if(difference > 0.25f) {
            [self performSelector:@selector(oneTapAction) withObject:nil afterDelay:0.25f];
        }else {
            //取消上一次的执行
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(oneTapAction) object: nil];
            [self touchPlayOrStop];
        }
        self.currentTime =  nowTime;
    }
}

-(void)oneTapAction{
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomBgView.alpha = self.backButton.alpha = self.isHandleViewHidden?0.0:1.0;
        
        //状态栏的隐藏与显示
        HRRotateVideoViewController *vc = (HRRotateVideoViewController *)self.controller;
        vc.statusHidden = self.isHandleViewHidden?YES:NO;
        [vc performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }];
    _isHandleViewHidden = !_isHandleViewHidden;
}

-(void)dealloc{
    NSLog(@"%s", __func__);
    //必须移除观察者对象
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
