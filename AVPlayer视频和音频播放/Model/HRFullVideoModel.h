//
//  HRFullVideoModel.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/16.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRFullVideoModel : NSObject

@property(nonatomic,assign)BOOL isFileVideo;
@property(nonatomic,strong)NSString *urlString;
//用playerItem才能保存视频源（很关键），playerItem内部会记录当前播放时长和播放总时长等信息
@property(nonatomic,strong)AVPlayerItem *playerItem;
@property(nonatomic,assign)BOOL isPlay;
@end

NS_ASSUME_NONNULL_END
