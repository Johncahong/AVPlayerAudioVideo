//
//  HRPlayerControlView.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/10/19.
//

#import "HRPlayerControlView.h"
#import "Masonry.h"

@implementation HRPlayerControlView

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"init bounds%@", self);
        [self addSubview:self.backButton];
        [self addSubview:self.bottomBgView];
        [self.bottomBgView addSubview:self.playButton];
        [self.bottomBgView addSubview:self.progressView];
        [self.bottomBgView addSubview:self.progressSlider];
        [self.bottomBgView addSubview:self.timeLabel];
        [self.bottomBgView addSubview:self.fullScreenButton];
        
        [self addSubview:self.toastLabel];
        [self addSubview:self.activity];
        [self addSubview:self.repeatBtn];
        self.activity.hidden = YES;
        self.repeatBtn.hidden = YES;
        
        // 添加子控件约束
        [self makeConstraints];
    }
    return self;
}

-(void)makeConstraints{
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.equalTo(self).offset(25);
        make.width.height.mas_equalTo(35);
    }];
    
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomBgView).offset(10);
        make.centerY.equalTo(self.bottomBgView);
        make.width.height.mas_equalTo(45);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.centerY.equalTo(self.playButton);
        make.right.equalTo(self.fullScreenButton.mas_left).offset(-110);
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.centerY.equalTo(self.playButton).offset(-1);
        make.right.equalTo(self.progressView).offset(1);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.progressSlider.mas_right).offset(0);
        make.centerY.equalTo(self.playButton);
    }];
    
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(8);
        make.right.equalTo(self.bottomBgView).offset(-10);
        make.centerY.equalTo(self.playButton);
        make.width.height.mas_equalTo(35);
    }];
    
    [self.toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@140);
        make.height.equalTo(@33);
    }];
    
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(@100);
    }];
    
    [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

#pragma mark - 接口
-(void)resetControlView{
    self.bottomBgView.hidden = NO;
    self.timeLabel.text = @"00:00/00:00";
    self.repeatBtn.hidden = YES;
    [self.activity startAnimating];
    self.progressSlider.value = 0;
    self.bottomBgView.userInteractionEnabled = NO;
}

#pragma mark - 懒加载
-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"player_icon_nav_back"] forState:UIControlStateNormal];
    }
    return _backButton;
}

-(UIButton *)playButton{
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"player_icon_play_2019"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_icon_pause_2019"] forState:UIControlStateSelected];
    }
    return _playButton;
}

-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        //进度颜色
        _progressView.progressTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        //轨道颜色
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

-(UISlider *)progressSlider{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.minimumTrackTintColor = [UIColor systemPinkColor];
        _progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return _progressSlider;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

-(UIView *)bottomBgView{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] init];
    }
    return _bottomBgView;
}

-(UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [[UIButton alloc] init];
        [_fullScreenButton setImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
    }
    return _fullScreenButton;
}

-(UILabel *)toastLabel{
    if (!_toastLabel) {
        _toastLabel = [[UILabel alloc] init];
        _toastLabel.textColor       = [UIColor whiteColor];
        _toastLabel.textAlignment   = NSTextAlignmentCenter;
        _toastLabel.font            = [UIFont systemFontOfSize:15.0];
        _toastLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _toastLabel.layer.cornerRadius = 10;
        _toastLabel.clipsToBounds = YES;
        _toastLabel.hidden = YES;
    }
    return _toastLabel;
}

-(UIActivityIndicatorView *)activity{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}

-(UIButton *)repeatBtn{
    if (!_repeatBtn) {
        _repeatBtn = [[UIButton alloc] init];
        [_repeatBtn setImage:[UIImage imageNamed:@"player_repeat_video"] forState:UIControlStateNormal];
    }
    return _repeatBtn;
}

@end
