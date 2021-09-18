//
//  HRFullScreenVideoView.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/14.
//

#define width   self.bounds.size.width
#define height  self.bounds.size.height

#import "HRFullScreenVideoView.h"

@interface HRFullScreenVideoView ()
{
    float  allTime;     //视频总长度
    double CurrentTime; //当前时间
}
@property (nonatomic, strong) UIImageView *logo;       //头像
@property (nonatomic, strong) UIImageView *like;       //喜欢
@property (nonatomic, strong) UIImageView *comment;    //评论
@property (nonatomic, strong) UIImageView *share;      //分享
@property (nonatomic, strong) UIProgressView *progress;//视频进度条
@property (nonatomic, strong) id timeObserve;
@end

@implementation HRFullScreenVideoView

- (UIImageView *)logo{
    if (_logo == nil) {
        _logo = [[UIImageView alloc] initWithFrame:CGRectMake(width-70, height-440, 60, 60)];
        _logo.image = [UIImage imageNamed:@"logo"];
        _logo.layer.cornerRadius = 30;
        _logo.layer.masksToBounds = YES;
        _logo.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logo;
}
- (UIImageView *)like{
    if (_like == nil) {
        _like = [[UIImageView alloc] initWithFrame:CGRectMake(width-60, height-350, 40, 40)];
        _like.image = [UIImage imageNamed:@"like"];
        _like.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _like;
}
- (UIImageView *)comment{
    if (_comment == nil) {
        _comment = [[UIImageView alloc] initWithFrame:CGRectMake(width-60, height-260, 40, 40)];
        _comment.image = [UIImage imageNamed:@"comment"];
        _comment.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _comment;
}
- (UIImageView *)share{
    if (_share == nil) {
        _share = [[UIImageView alloc] initWithFrame:CGRectMake(width-60, height-190, 40, 40)];
        _share.image = [UIImage imageNamed:@"share"];
        _share.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _share;
}
- (UIImageView *)playImageView{
    if (_playImageView == nil) {
        CGFloat w = 65;
        _playImageView = [[UIImageView alloc] initWithFrame:CGRectMake((width-w)/2, (height-w)/2, w, w)];
        _playImageView.image = [UIImage imageNamed:@"play"];
        _playImageView.contentMode = UIViewContentModeScaleAspectFit;
        _playImageView.hidden = YES;
    }
    return _playImageView;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSubView];
    }
    return self;
}

-(void)setSubView{
    self.player = [[AVPlayer alloc] initWithPlayerItem:nil];
    AVPlayerLayer * playLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playLayer.videoGravity = AVLayerVideoGravityResize;
    playLayer.frame = CGRectMake(0, 0, width, height);
    [self.contentView.layer addSublayer:playLayer];
    
    [self.contentView addSubview:self.logo];
    
    [self.contentView addSubview:self.like];
    
    [self.contentView addSubview:self.comment];
    
    [self.contentView addSubview:self.share];
    
    [self.contentView addSubview:self.playImageView];
    
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, height - 50, width, 10)];
    _progress.progressTintColor = [UIColor whiteColor];
    _progress.trackTintColor = [UIColor lightGrayColor];
    [_progress setProgress:0.0 animated:YES];
    [self.contentView addSubview:_progress];
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create(0, 0);
    
    //该方法返回一个观察者，销毁时需要主动移除观察者：[player removeTimeObserver:timeObserve]
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(10, 10) queue:queue usingBlock:^(CMTime time) {
        //当前播放时间
        NSTimeInterval nowTime = CMTimeGetSeconds(time);
        //总时间
        NSTimeInterval totaltime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        float result = nowTime/totaltime;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //滑块进度
            [weakSelf.progress setProgress:result animated:NO];
//            NSLog(@"%f",result);
            if (result == 1.0) {
                CMTime ttt = CMTimeMake(1, 1);
                [weakSelf.player.currentItem seekToTime:ttt completionHandler:^(BOOL finished) {
                    [weakSelf.player play];
                }];
            }
        });
    }];
}

-(void)setModel:(HRFullVideoModel *)model{
    _model = model;
    [self.player replaceCurrentItemWithPlayerItem:model.playerItem];
    self.playImageView.hidden = model.isPlay;
}

-(void)play{
    [self.player play];
    self.isPlay = YES;
    self.playImageView.hidden = YES;
}

-(void)pause{
    [self.player pause];
    self.isPlay = NO;
}

-(void)touchPlayOrStop{
    if (_isPlay) {
        _isPlay = NO;
        [self.player pause];
        self.playImageView.hidden = NO;
    }else{
        _isPlay = YES;
        [self.player play];
        self.playImageView.hidden = YES;
    }
    _model.isPlay = _isPlay;
}
//单击
-(void)oneTapAction{
    [self touchPlayOrStop];
}
-(void)doubleTapAction:(CGPoint)point{
    __block int X = (int)point.x;
    int Y = (int)point.y;
    //设置图片显示之后消失
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    image.image = [UIImage imageNamed:@"aixin"];
    image.center = point;
    [self addSubview:image];
    [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        //arc4random()%50：取值范围[0, 49]
        //(arc4random() % 50)-50的取值范围：[-50, -1]
        X += (arc4random() % 50)-50;
        image.frame = CGRectMake(X, Y-200, 80, 80);
        image.alpha = 0.5;
    } completion:^(BOOL finished) {
        [image removeFromSuperview];
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    double nowTime = CACurrentMediaTime();
    double difference = nowTime - CurrentTime;
    if(difference > 0.25f) {
        [self performSelector:@selector(oneTapAction) withObject:nil afterDelay:0.25f];
    }else {
        //取消上一次的执行
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(oneTapAction) object: nil];
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:touch.view];
        [self doubleTapAction:point];
    }
    CurrentTime =  nowTime;
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
