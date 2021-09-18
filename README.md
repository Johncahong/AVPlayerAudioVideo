### 什么是AVPlayer
- AVPlayer存在于AVFoundation框架中，它是一个视频播放器，用来播放视频，但也可以用来播放音乐，播放音乐时不需要实现界面。换句话说，只要掌握了视频播放，音频播放自然就掌握了。
- AVPlayerItem：和媒体资源存在对应关系，管理媒体资源的信息和状态。它的初始化需要URL或AVAsset。
- AVPlayer：播放器，控制资源的播放和暂停，AVPlayerItem是它的属性，它的初始化需要URL或AVPlayerItem。
```c
+ (instancetype)playerWithURL:(NSURL *)URL;
+ (instancetype)playerWithPlayerItem:(nullable AVPlayerItem *)item;
```
- AVPlayerLayer：播放器图层，用于展示视频内容，AVPlayer是它的属性，它的初始化需要AVPlayer。如果是播放音频，则不需要创建AVPlayerLayer。
```c
+ (AVPlayerLayer *)playerLayerWithPlayer:(nullable AVPlayer *)player
```
- AVPlayerItem、AVPlayer、AVPlayerLayer三者关系，做个类比：
AVPlayerItem是光盘，AVPlayer是dvd影碟机，AVPlayerLayer是电视机屏幕。

### 视频播放功能实现
#### 1.通过网络链接播放视频资源
```c
//url有中文时需要URL编码
NSURL *url = [NSURL URLWithString:[self.str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
playerLayer.frame = CGRectMake(0, 50, self.view.frame.size.width, 200);
[self.view.layer addSublayer:playerLayer];
```
#### 2.常用操作
- 播放和暂停
```c
[player play];
[player pause];
```
- 替换播放资源
```c
[player replaceCurrentItemWithPlayerItem:videoItem];
```
#### 3.监听播放进度
- 使用`addPeriodicTimeObserverForInterval:queue:usingBlock:`监听播放器的进度，常用于指示播放进度，获取播放时长等信息。
1）Interval参数表示回调的间隔时间，block是每到一个间隔时间执行一次。
例如Interval传CMTimeMake(1, 10)，1表示当前有1帧，10表示每秒10帧，1/10=0.1，即player在播放中时每0.1秒执行一次block，包括开始播放、暂停播放也会回调。
2）方法返回一个观察者对象，当不再播放时，要移除该观察者。
添加观察者
```c
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        weakSelf.playTime = [NSString stringWithFormat:@"%.f",current];
        weakSelf.playDuration = [NSString stringWithFormat:@"%.2f",total];
        if (weakSelf.slider.isTracking == NO) {
            weakSelf.slider.value = current / total;
        }
    }];
```
 移除观察者
```c
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
    }
```
#### 4.移动滑块播放指定时刻的视频帧
- 使用`seekToTime:`或`seekToTime:completionHandler:`或`seekToTime:toleranceBefore:toleranceAfter:completionHandler:`播放指定时刻的视频内容。
精确搜索某一时刻的视频帧可能会导致额外的解码延迟，`seekToTime:`默认不是精确搜索，而是有一个小范围的误差。
`seekToTime:toleranceBefore:toleranceAfter:completionHandler:`的搜索的范围是[time-toleranceBefore, time+toleranceAfter]，当toleranceBefore和toleranceAfter设置为kCMTimePositiveInfinity时，执行效果等同于`seekToTime:completionHandler:`
```c
    [self.player seekToTime:goalTime toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL finished) {
    }];
```

#### 遇到的问题
- 播放时，扬声器没有声音，插上耳机才有声音。
原因是app扬声器默认跟随系统声音模式，而手机调了静音模式，因此扬声器跟随静音模式，没有声音。
解决方式：设置Category，让扬声器不跟随系统声音模式。
```c
    //必须设置，否则扬声器默认跟随系统声音模式
    //AVAudioSessionCategoryPlayAndRecord模式能播放能录音，该模式下声音默认出口是听筒（戴耳机才有声音），切换到扬声器通过以下方式
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
```
- 当反复快速移动滑块时，滑块会出现**跳跃**的现象。
这是由于移动滑块时，会调用`seekToTime:`，该方法用于搜索并播放指定视频帧，执行时需要一点时间，不会立马搜索并播放到指定视频帧，此时`addPeriodicTimeObserverForInterval:queue:usingBlock:`回调会设置滑块的位置，出现手指已让滑块移动到某一位置，突然有一瞬间滑块回到之前的位置，然后立马又回到手指停留的位置。
解决方式：用`seekToTime:toleranceBefore:toleranceAfter:completionHandler:`代替`seekToTime:`，搜索并播放到指定视频帧会有completionHandler的回调，获得该回调后再设置滑块的位置。具体处理细节详见项目。

### 项目
- 以下项目是基于AVPlayer的实际运用，实现音频播放、横竖屏视频切换播放、类似抖音的竖屏全屏播放效果。
项目地址：[AVPlayerAudioVideo](https://github.com/Johncahong/AVPlayerAudioVideo)
1.音频播放器效果：
2.竖屏和横屏的切换效果：
3.类似抖音竖屏全屏的效果：
竖屏全屏用UICollectionView实现，只创建了三个UICollectionViewCell视图实例。无论有多少视频需要播放，都是复用这三个UICollectionViewCell视图实例，有效控制内存大小，避免内存加载过大、内存爆满的情况。
UICollectionViewCell复用时有一个难点，就是记录视频当前已播放的位置，一开始用CMTime来保存发现不行，然后用CMTimeValue和CMTimeScale分别记录也是存在各种问题，后来使用AVPlayerItem来保存已播放位置才彻底解决。
