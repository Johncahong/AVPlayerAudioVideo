//
//  HRLrcMessage.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import "HRLrcMessage.h"

@implementation HRLrcMessage

- (NSString *)songDetail
{
    return [NSString stringWithFormat:@"\n艺人:%@\n曲名:%@\n专辑:%@\n作曲:%@\n", _ar, _ti, _al, _by];
}

@end
