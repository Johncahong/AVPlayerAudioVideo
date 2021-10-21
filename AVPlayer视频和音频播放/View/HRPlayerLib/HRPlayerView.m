//
//  HRPlayerView.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/10/19.
//

#import "HRPlayerView.h"
#import "HRPlayerControlView.h"
#import "Masonry.h"

@interface HRPlayerView ()
@property (nonatomic, strong) HRPlayerControlView *controlView;
@property (nonatomic,weak)UIViewController *controller;
@property (assign, nonatomic) double currentTime; //当前时间;

@property (nonatomic, assign) BOOL isUpdateSeek;//是否查找定位到指定帧
@property (nonatomic, strong) id timeObserve;
@property (nonatomic, assign) BOOL isHandleViewHidden;//可操作的子控件是否隐藏
@property (nonatomic, assign) BOOL isStartPlay;
@end

@implementation HRPlayerView

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.player = [AVPlayer playerWithPlayerItem:nil];
    }
    return self;
}

#pragma mark - 初始化后的配置
-(void)setModel:(HRFullVideoModel *)model addController:(UIViewController *)controller{
    _model = model;
    //这里控制器属性必须弱引用，否则会造成循环引用，导致dealloc永远不执行
    self.controller = controller;
    
    [self.player replaceCurrentItemWithPlayerItem:model.playerItem];
    
    [self addNotification];
    
    self.isStartPlay = YES;
    self.controlView.progressSlider.value = 0;
    self.isUpdateSeek = YES;
    [self.controlView.progressView setProgress:0.0];
    [self addUpProgress];
    [self.controlView.activity startAnimating];
    
    self.controlView.bottomBgView.alpha = 0.0;
    self.controlView.bottomBgView.userInteractionEnabled = !model.isPlay;
    
    //默认隐藏
    self.isHandleViewHidden = model.isPlay;
    [self oneTapAction];
}

-(void)addNotification{
    // 监听loadedTimeRanges属性(缓存进度)
    [self.model.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.model.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self.controlView.fullScreenButton addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.backButton addTarget:self action:@selector(turnScreenPortrait:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.playButton addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.repeatBtn addTarget:self action:@selector(repeatPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.progressSlider addTarget:self action:@selector(progressSliderChange:forEvent:) forControlEvents:UIControlEventValueChanged];
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
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(10, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        //开始播放的时候player.currentItem.duration.timescale大于0
        if (wself.isStartPlay && wself.player.currentItem.duration.timescale>0) {
            wself.controlView.bottomBgView.userInteractionEnabled = YES;
            [wself.controlView.activity stopAnimating];
            wself.isStartPlay = NO;
        }
        
        //视频总时长（单位秒）
        float total = wself.player.currentItem.duration.value/ wself.player.currentItem.duration.timescale;
        //当前播放时长（单位秒）
        float current = wself.player.currentItem.currentTime.value / wself.player.currentItem.currentTime.timescale;
        
        if (wself.isUpdateSeek == YES) {
            wself.controlView.progressSlider.value = current / total;
        }
        wself.controlView.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d", (int)current/60, (int)current%60, (int)total/60, (int)total%60];
        NSLog(@"%f--timescale:%d",wself.controlView.progressSlider.value, wself.player.currentItem.duration.timescale);
        if (current / total == 1) {
            
        }
    }];
}

#pragma mark - 对外的方法
-(void)play{
    [self.player play];
    self.isPlay = YES;
    self.controlView.playButton.selected = YES;
}
-(void)pause{
    [self.player pause];
    self.isPlay = NO;
    self.controlView.playButton.selected = NO;
}

#pragma mark - 内部方法
///当前视频播放完毕的通知
- (void)moviePlayDidEnd:(NSNotification *)notification{
    NSLog(@"视频播放完毕");
    self.controlView.repeatBtn.hidden = NO;
    self.controlView.bottomBgView.hidden = YES;
    
    //这里调用seekToTime目的是调整播放完毕的精度，否则app进入后台再回到前台，视频由于精度问题仍会播放几秒
    [self.player seekToTime:CMTimeMake(self.player.currentItem.duration.value, self.player.currentItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
    }];
}

-(void)repeatPlay:(UIButton *)button{
    [self resetControlView];
    //seekToTime完成后默认是暂停状态
    [self.player seekToTime:CMTimeMake(0, self.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            if (self.isPlay) {
                [self.player play];
            }
        }
    }];
}

- (void)resetControlView{
    [self.controlView resetControlView];
    self.isStartPlay = YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            // 暂时没有添加拖动手势
            // 加载完成后，再添加平移手势
            // 添加平移手势，用来控制音量、亮度、快进快退
//                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
//                pan.delegate                = self;
//                [self addGestureRecognizer:pan];
            NSLog(@"开始加载");
        } else if (self.player.currentItem.status == AVPlayerItemStatusFailed){
            NSError *error = [self.player.currentItem error];
            NSLog(@"视频加载失败===%@",error.description);
            self.controlView.toastLabel.hidden = NO;
            self.controlView.toastLabel.text = @"视频加载失败";
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CGFloat totalDuration = CMTimeGetSeconds(self.model.playerItem.duration);
        [self.controlView.progressView setProgress:timeInterval / totalDuration animated:NO];
    }
}

/**
 *  计算缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)progressSliderChange:(UISlider *)sender forEvent:(UIEvent *)event {
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
            
            //视频总时长（单位秒）
            float current = (self.controlView.progressSlider.value * self.player.currentItem.duration.value)/ self.player.currentItem.duration.timescale;
            self.controlView.toastLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)current/60, (int)current%60];
            self.controlView.toastLabel.hidden = NO;
        }
            break;
        case UITouchPhaseEnded:
        {
            NSLog(@"结束拖动");
            self.isUpdateSeek = NO;
            self.controlView.toastLabel.hidden = YES;
            [self.controlView.activity startAnimating];
            [self.player pause];
            
            CMTime goalTime = CMTimeMake(self.controlView.progressSlider.value * self.player.currentItem.duration.value, self.player.currentItem.duration.timescale);
            //调用seekToTime方法后，需要等零点几秒才会定位到指定帧，定位完成（画面刷新）有个block回调，定位完成后默认是暂停状态
            //精度越准确，花费的时间越长，仅在滑块滑到最后一秒时才精准定位
            CMTime precisionTime;
            if (self.controlView.progressSlider.value == 1) {
                precisionTime = kCMTimeZero;
            }else{
                precisionTime = kCMTimePositiveInfinity;
            }
            [self.player seekToTime:goalTime toleranceBefore:precisionTime toleranceAfter:precisionTime completionHandler:^(BOOL finished) {
                if (finished) {
                    if (self.isPlay) {
                        [self.player play];
                    }
                    self.isUpdateSeek = YES;
                    [self.controlView.activity stopAnimating];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)playClick:(UIButton *)sender {
    [self touchPlayOrStop];
}

-(void)touchPlayOrStop{
    if (_isPlay) {
        _isPlay = NO;
        [self.player pause];
        self.controlView.playButton.selected = NO;
    }else{
        _isPlay = YES;
        [self.player play];
        self.controlView.playButton.selected = YES;
    }
    _model.isPlay = _isPlay;
}

//全屏
- (void)fullScreenBtnClick:(UIButton *)sender {
    [self turnOrientation:UIInterfaceOrientationLandscapeRight];
}

//竖屏
- (void)turnScreenPortrait:(UIButton *)sender {
    if (UIDevice.currentDevice.orientation != UIDeviceOrientationPortrait) {
        [self turnOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self.controller.navigationController popViewControllerAnimated:YES];
    }
}

-(void)turnOrientation:(UIInterfaceOrientation)orientaion{
    [self configViewOrientation:orientaion];
    NSNumber *number = [NSNumber numberWithInt:(int)orientaion];
    [[UIDevice currentDevice] setValue:number forKey:@"Orientation"];
}

-(void)configViewOrientation:(UIInterfaceOrientation)orientaion{
    switch (orientaion) {
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
        {
            self.controller.navigationController.navigationBar.hidden = YES;
            self.controlView.fullScreenButton.hidden = YES;
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            self.controller.navigationController.navigationBar.hidden = NO;
            self.controlView.fullScreenButton.hidden = NO;
        }
            break;
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //将像素point由point所在视图转换到目标视图view中，返回在目标视图view中的像素值
    CGPoint p = [self convertPoint:point toView:self.controlView.bottomBgView];
    if (![self.controlView.bottomBgView pointInside:p withEvent:event]) {
        
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
        self.controlView.bottomBgView.alpha = self.controlView.backButton.alpha = self.isHandleViewHidden?0.0:1.0;
        
        //状态栏的隐藏与显示
        BOOL statusHidden = self.isHandleViewHidden?YES:NO;
        [self.controller setValue:@(statusHidden) forKey:@"statusHidden"];
        [self.controller performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
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
    [_model.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [_model.playerItem removeObserver:self forKeyPath:@"status" context:nil];
}

-(HRPlayerControlView *)controlView{
    if (!_controlView) {
        _controlView = [[HRPlayerControlView alloc] init];
        [self addSubview:_controlView];
        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _controlView;
}
@end
