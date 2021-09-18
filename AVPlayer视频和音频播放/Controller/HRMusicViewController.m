//
//  HRMusicViewController.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import "HRMusicViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "HRSong.h"
#import "HRLrcManager.h"
#import "HRLrcMessage.h"
@interface HRMusicViewController ()

@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
//表示每一句歌词
@property (weak, nonatomic) IBOutlet UILabel *geciLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property(nonatomic, strong)dispatch_block_t task;

@property(weak,nonatomic)NSString *songStr;
@property(nonatomic, assign)BOOL isUpdateSeek;
@property(nonatomic, strong)id timeobserver;

- (IBAction)playBtnClicked:(id)sender;
- (IBAction)prevBtnClicked:(id)sender;
- (IBAction)nextBtnClicked:(id)sender;

- (IBAction)circulateBtnClicked:(id)sender;
- (IBAction)randomBtnClicked:(id)sender;


//播放器，用来播放网络和本地的音频文件
@property(nonatomic,strong)AVPlayer *player;
//歌曲列表数组
@property(nonatomic,strong)NSMutableArray *songsArray;
//当前播放歌曲的序号
@property(nonatomic,assign)NSInteger currentSongIndex;
@end

@implementation HRMusicViewController

#pragma mark - lazy initialization

//懒加载  用到的时候才创建,重写getter方法
//用来返回一个存有歌曲对象的数组   对象信息－－1.歌曲名称  2.歌曲相对路径
-(NSMutableArray *)songsArray{
    if(_songsArray==nil){
        _songsArray = [NSMutableArray new];
        
        NSArray *mp3Paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp3" inDirectory:nil];
        
        for(NSString *path in mp3Paths){
            HRSong *song = [HRSong new];
            song.songURLString = path;
            //  a/b/c/song1.mp3这样会取到最后的元素"song.mp3"
            song.songName = [[[[path pathComponents] lastObject] componentsSeparatedByString:@"."] firstObject];
            NSLog(@"%@",song.songName);
            [_songsArray addObject:song];
        }
    }
    NSLog(@"%d", (int)_songsArray.count);
    return _songsArray;
}

//懒加载二
-(AVPlayer *)player{
    if(!_player){
        if (self.songsArray.count==0) {
            return nil;
        }
        //1获取当前歌曲的url
        HRSong *currentSong = self.songsArray[self.currentSongIndex];
        
        //生成url对象
        NSURL *url = [NSURL fileURLWithPath:currentSong.songURLString];
        
        //创建avplayeritem［类比光盘］
        AVPlayerItem *item =[[AVPlayerItem alloc] initWithURL:url];
        
        //创建avplayer［类比dvd影碟机］
        _player = [AVPlayer playerWithPlayerItem:item];
        
        //显示当前歌曲的名称
        self.songNameLabel.text = [NSString stringWithFormat:@"01.%@",currentSong.songName];

    }
    return _player;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isUpdateSeek = YES;
    self.progressSlider.value = 0;
    
    //必须设置，否则扬声器默认跟随系统声音模式
    //AVAudioSessionCategoryPlayAndRecord 模式能播放能录音，该模式下声音默认出口是听筒（戴耳机才有声音），切换到扬声器通过以下方式
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    __weak typeof(self) weakSelf = self;
    //参数：1.周期时间，1.1CMTime{value,timescale},value代表总帧数，timescale代表帧率，
    //{60,30},{30,15}时间＝帧数／帧率
    //     2.dispatch_queue
    //     3.block
    //该方法返回一个观察者，销毁时需要主动移除观察者：[player removeTimeObserver:timeObserve]
    
    self.timeobserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_queue_create("music.queue", DISPATCH_QUEUE_CONCURRENT) usingBlock:^(CMTime time) {
        
        //获取当前播放时间
        CMTime current = weakSelf.player.currentItem.currentTime;
        float currentSeconds = current.value/current.timescale;
        
        //获取总时长
        CMTime duration = weakSelf.player.currentItem.duration;
        float durationSeconds = duration.value * 1.0/duration.timescale;
        
        //计算播放百分比
        float progress = currentSeconds/durationSeconds;
        
        //获取当前歌曲歌词路径
        NSString *songtxtStr = [[NSBundle mainBundle] pathForResource:[weakSelf.songsArray[weakSelf.currentSongIndex] getSongName] ofType:@"txt"];
        HRLrcManager * manager = [[HRLrcManager alloc] initWithFile:songtxtStr];
        
        //设置slider当前进度
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.isUpdateSeek == YES){
                weakSelf.progressSlider.value = progress;
                //歌声和歌词时间有偏差
                weakSelf.geciLabel.text = [manager lrcInTime:currentSeconds-1.5];
            }

            //设置label 00:00
            int intcs = currentSeconds;
            int intds = durationSeconds;
            weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",intcs/60,intcs%60];
            weakSelf.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",intds/60,intds%60];
        });
    }];
    
    //获取播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextSong) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self playBtnClicked:self.playButton];
}

-(void)selectState:(UIButton *)button{
    for(int i=0;i<2;i++){
        UIButton *button2= [self.view viewWithTag:101+i];
        button2.selected = NO;
    }
    button.selected = YES;
}
-(void)nextSong{
    UIButton *button1 =(UIButton *)[self.view viewWithTag:101];//单曲循环
    UIButton *button2 = (UIButton *)[self.view viewWithTag:102];//随机播放
    if(button1.selected ==YES){
     
        [self playCurrentSong];
        //开始播放
        [self.player play];
        
    }else if(button2.selected == YES){
        self.currentSongIndex = (int)arc4random() % _songsArray.count;
        //prevBtnClicked和nextBtnClicked都用到，所以封装
        [self playCurrentSong];
        
        //开始播放
        [self.player play];
    }else{
        self.currentSongIndex ++;
        if(self.currentSongIndex >self.songsArray.count -1){
            self.currentSongIndex = 0;
        }
        [self playCurrentSong];
        
        //开始播放
        [self.player play];
    }
    
}

- (IBAction)playBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player play];
    }else{
        [self.player pause];
    }
}

- (IBAction)prevBtnClicked:(id)sender {
    self.currentSongIndex --;
    if(self.currentSongIndex <0){
        self.currentSongIndex =self.songsArray.count-1;
    }
    //prevBtnClicked和nextBtnClicked都用到，所以封装
    [self playCurrentSong];
    
    //开始播放
    [self.player play];
}

- (IBAction)nextBtnClicked:(id)sender {
    self.currentSongIndex ++;
    if(self.currentSongIndex >self.songsArray.count -1){
        self.currentSongIndex = 0;
    }
    [self playCurrentSong];
    //开始播放
    [self.player play];
}

- (IBAction)sliderChangeValue:(UISlider *)sender forEvent:(UIEvent *)event {
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseBegan:
        {
            NSLog(@"开始拖动");
            if (self.task) {
                dispatch_block_cancel(self.task);
            }
            self.isUpdateSeek = NO;
        }
            break;
        case UITouchPhaseMoved:
        {
            NSLog(@"拖动ing");
        }
            break;
        case UITouchPhaseEnded:
        {
            NSLog(@"结束拖动");
            CMTime goalTime = CMTimeMake(sender.value * self.player.currentItem.duration.value, self.player.currentItem.duration.timescale);
            
            __weak typeof(self) weakSelf = self;
            
            weakSelf.task = dispatch_block_create(0, ^{
                NSLog(@"执行任务");
                weakSelf.isUpdateSeek = YES;
            });
            //调用seekToTime方法后，需要等零点几秒才会定位到指定帧，定位成功（画面刷新）有个block回调
            [self.player seekToTime:goalTime completionHandler:^(BOOL finished) {
                if (finished) {
                    //防止移动时，滑块出现跳跃延迟
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.task);
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (IBAction)circulateBtnClicked:(id)sender {
    UIButton *btn1 = (UIButton *)sender;
    btn1.tag = 101;
    [self selectState:btn1];
}

- (IBAction)randomBtnClicked:(id)sender {
    UIButton *btn1 = (UIButton *)sender;
    btn1.tag = 102;
    [self selectState:btn1];
}
-(void)playCurrentSong{
    if (self.songsArray.count==0) {
        return;
    }
    self.playButton.selected = YES;
    
    //切换player播放器当前的item
    //0.获取song对象
    HRSong *song = self.songsArray[self.currentSongIndex];
    //1.创建avplayeritem
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:song.songURLString]];
    //2.切换播放器当前的item
    [self.player replaceCurrentItemWithPlayerItem:item];
    //3.更换label内容
    self.songNameLabel.text =  [NSString stringWithFormat:@"%02d.%@",(int)self.currentSongIndex+1,song.songName];
}

-(void)dealloc{
    NSLog(@"%s", __func__);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeobserver) {
        [self.player removeTimeObserver:self.timeobserver];
    }
}
@end
