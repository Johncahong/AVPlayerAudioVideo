//
//  ViewController.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/10.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"--ViewController");
    
    UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    [titleBtn setTitle:@"共同进步，给个star😁😏❤️" forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.navigationItem.titleView = titleBtn;
}


@end
