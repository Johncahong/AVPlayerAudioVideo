//
//  HRFullScreenVideoView.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/14.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "HRFullVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HRFullScreenVideoView : UICollectionViewCell

@property (nonatomic, strong)AVPlayer      *player;   //播放器
@property (nonatomic, strong)UIImageView   *playImageView; //开始暂停
@property (nonatomic, assign)BOOL isPlay;
@property (nonatomic, strong)HRFullVideoModel *model;

-(void)play;
-(void)pause;
@end

NS_ASSUME_NONNULL_END
