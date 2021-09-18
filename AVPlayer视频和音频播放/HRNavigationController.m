//
//  HRNavigationController.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/13.
//

#import "HRNavigationController.h"

@interface HRNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation HRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakself = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //设置右滑返回手势的代理为自身(自定义导航栏的代理要做设置，否则手势返回失效)
        self.interactivePopGestureRecognizer.delegate = (id)weakself;
    }
}

#pragma mark - UIGestureRecognizerDelegate
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //侧滑返回手势是否禁用
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

/* 导航栏控制器会拦截它rootViewController的preferredStatusBarStyle，
   所以必须导航栏控制器的preferredStatusBarStyle
*/
-(UIStatusBarStyle)preferredStatusBarStyle{
    return self.topViewController.preferredStatusBarStyle;
}

@end
