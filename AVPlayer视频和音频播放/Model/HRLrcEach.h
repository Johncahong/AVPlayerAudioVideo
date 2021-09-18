//
//  HRLrcEach.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//数据模型 存储每句歌词
@interface HRLrcEach : NSObject

@property float seconds;        //每句歌词对应的秒数
@property NSString * lrcEach;   //每句歌词的内容

@end

NS_ASSUME_NONNULL_END
