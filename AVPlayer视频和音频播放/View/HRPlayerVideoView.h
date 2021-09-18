//
//  HRPlayerVideoView.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HRRotateVideoViewController.h"
#import "HRFullVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HRPlayerVideoView : UIView

@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,assign)BOOL isPlay;
@property(nonatomic,strong)HRFullVideoModel *model;
-(void)setModel:(HRFullVideoModel *)model addController:(UIViewController *)controller;

-(void)play;
-(void)pause;
@end

NS_ASSUME_NONNULL_END
