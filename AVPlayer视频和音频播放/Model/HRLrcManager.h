//
//  HRLrcManager.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import <Foundation/Foundation.h>
#import "HRLrcMessage.h"

NS_ASSUME_NONNULL_BEGIN

//歌词管理类，负责解析歌词，管理歌词，输入时间，返回对应歌词
@interface HRLrcManager : NSObject

@property (readonly) HRLrcMessage * message;

//传入歌词路径，初始化歌词管理类
- (id)initWithFile:(NSString *)path;
//给定时间，返回歌词
- (NSString *)lrcInTime:(float)time;

@end

NS_ASSUME_NONNULL_END
