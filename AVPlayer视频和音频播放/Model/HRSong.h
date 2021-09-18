//
//  HRSong.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRSong : NSObject

@property(nonatomic,copy)NSString *songName;
@property(nonatomic,copy)NSString *songURLString;

-(NSString *)getSongName;

@end

NS_ASSUME_NONNULL_END
