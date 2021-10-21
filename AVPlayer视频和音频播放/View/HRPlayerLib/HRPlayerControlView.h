//
//  HRPlayerControlView.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRPlayerControlView : UIView

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIProgressView *progressView;//缓存进度
@property (strong, nonatomic) UISlider *progressSlider;//播放进度
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIView *bottomBgView;
@property (strong, nonatomic) UIButton *fullScreenButton;

@property (nonatomic,strong) UILabel *toastLabel;//吐丝，加载失败和成功提示
@property (nonatomic,strong) UIActivityIndicatorView *activity;//系统菊花
@property (nonatomic,strong) UIButton *repeatBtn;//重播按钮

//重播时要复原
- (void)resetControlView;
@end

NS_ASSUME_NONNULL_END
