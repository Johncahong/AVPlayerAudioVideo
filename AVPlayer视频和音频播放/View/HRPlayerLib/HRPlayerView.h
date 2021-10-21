//
//  HRPlayerView.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/10/19.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HRFullVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HRPlayerView : UIView

@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,assign)BOOL isPlay;
@property(nonatomic,strong)HRFullVideoModel *model;
-(void)setModel:(HRFullVideoModel *)model addController:(UIViewController *)controller;

-(void)play;
-(void)pause;
-(void)configViewOrientation:(UIInterfaceOrientation)orientaion;
@end

NS_ASSUME_NONNULL_END
