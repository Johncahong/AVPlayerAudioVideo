//
//  HRLrcMessage.h
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRLrcMessage : NSObject

//   [ar:艺人名]
//　　[ti:曲名]
//　　[al:专辑名]
//　　[by:编者（歌词的人）]
//　　[offset:时间补偿值]其单位是毫秒，正值表示整体提前，负值相反。这是用于总体调整显示快慢的。

@property NSString * ar;
@property NSString * ti;
@property NSString * al;
@property NSString * by;
@property float offset;

- (NSString *)songDetail;

@end

NS_ASSUME_NONNULL_END
