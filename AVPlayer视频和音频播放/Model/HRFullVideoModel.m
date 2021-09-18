//
//  HRFullVideoModel.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/16.
//

#import "HRFullVideoModel.h"

@implementation HRFullVideoModel

//懒加载方式初始化视频源
-(AVPlayerItem *)playerItem{
    if (!_playerItem) {
        if (_isFileVideo) {
            _playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:_urlString]];
        }else{
            NSURL *url = [NSURL URLWithString:[_urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            _playerItem = [[AVPlayerItem alloc] initWithURL:url];
        }
    }
    return _playerItem;
}

@end
