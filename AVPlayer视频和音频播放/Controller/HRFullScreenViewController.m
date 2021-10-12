//
//  HRFullScreenViewController.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/14.
//

#define width   self.view.bounds.size.width
#define height  self.view.bounds.size.height

#import "HRFullScreenViewController.h"
#import "HRFullScreenVideoView.h"
#import <AVKit/AVKit.h>
#import "HRFullVideoModel.h"

@interface HRFullScreenViewController ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray * videoList;

@property (nonatomic, strong) HRFullScreenVideoView * nextVideoView;
@property (nonatomic, strong) NSIndexPath *nextIndexPath;
@end

@implementation HRFullScreenViewController

static NSString *cellID = @"FullScreenCell";

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    //iOS11后，scrollView默认会下移状态栏的高度，以下代码是不做下移处理
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //必须设置，否则扬声器默认跟随系统声音模式
    //能播放能录音，该模式下声音默认出口是听筒（戴耳机才有声音），切换到扬声器通过以下方式
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    //监听进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //监听进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.videoList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HRFullScreenVideoView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.model = self.videoList[indexPath.item];
    return cell;
}

//cell刚移入屏幕时回调，indexPath对应刚移入屏幕的cell下标
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"willDisplayCell:%d", (int)indexPath.item);

    if (self.nextVideoView==nil) {
        //一进入默认播放
        HRFullScreenVideoView *view = (HRFullScreenVideoView *)cell;
        [view play];
    }
    self.nextVideoView = (HRFullScreenVideoView *)cell;
    self.nextIndexPath = indexPath;
}

//cell完全移出屏幕时回调，indexPath对应完全移出屏幕的cell下标
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"didEndDisplayingCell:%d", (int)indexPath.item);

    HRFullScreenVideoView *preVideoView =(HRFullScreenVideoView *)cell;
    if (self.nextIndexPath != indexPath) {
        if (preVideoView.model.isPlay) {
            [preVideoView pause];
        }
        
        if (self.nextVideoView.model.isPlay) {
            [self.nextVideoView play];
        }
    }
}

#pragma mark - 通知
-(void)enterForeground:(NSNotification *)notification{
    HRFullVideoModel *model = self.videoList[self.nextIndexPath.item];
    if (model.isPlay) {//原本是播放的，就恢复继续播放
        [self.nextVideoView play];
    }
}
-(void)enterBackground:(NSNotification *)notification{
    HRFullVideoModel *model = self.videoList[self.nextIndexPath.item];
    if (model.isPlay) {//正在播放的，就让它暂停播放（必须用model属性判断）
        [self.nextVideoView pause];
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)videoList{
    if (!_videoList) {
        _videoList = [[NSMutableArray alloc] init];
        NSArray *arr = @[@"v4",@"v3",@"v2",@"v1",@"v5"];
        /*无论多少视频都不会导致内存爆满，因为cell始终只创建了三个，
          而视频源（AVPlayerItem）在model中，基本上不占用内存
         */
        for (int i=0; i<100; i++) {
            for (int j=0; j<arr.count; j++) {
                NSString *localPath = [[NSBundle mainBundle] pathForResource:arr[j] ofType:@"mov"];
                HRFullVideoModel *model = [[HRFullVideoModel alloc] init];
                model.isFileVideo = YES;
                model.urlString = localPath;
                model.isPlay = YES;
                //不在这里初始化playerItem，因为如果很多playerItem都要初始化，会挺耗时
//                model.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:localPath]];
                [_videoList addObject:model];
            }
        }
    }
    return _videoList;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(width, height);
        //竖直方向布局，指cell的最小行间距
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[HRFullScreenVideoView class] forCellWithReuseIdentifier:cellID];
    }
    return _collectionView;
}

@end
