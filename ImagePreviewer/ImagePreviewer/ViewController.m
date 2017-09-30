//
//  ViewController.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ViewController.h"
#import "PhotoBroswer.h"

@interface ViewController ()

@property (nonatomic,assign) CGFloat test;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"[self test] = %f", [self test]);
    NSLog(@"self.test = %f", self.test);
    [self setupUI];
}

- (CGFloat)test {
    _test = 100;
    return 10;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, 100, 50);
    [btn setTitle:@"图片浏览器" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushToBroswer) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    btn.center = self.view.center;
}
    
- (void)pushToBroswer {
    PhotoBroswer *broswer = [PhotoBroswer new];
    [self.navigationController pushViewController:broswer animated:YES];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
