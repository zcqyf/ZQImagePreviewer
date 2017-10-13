//
//  BackViewController.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "BackViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface BackViewController ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImage *backgroundImage;

- (UIImage *)captureView:(UIView *)view;

@end

@implementation BackViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //  Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _imageView.image = _backgroundImage;
    _imageView.alpha = 0.9;
}

- (void)updateWithViewController:(UIViewController *)viewController {
    self.backgroundImage = [self captureView:viewController.view];
}

- (UIImage *)captureView:(UIView *)view {
    CGRect rect = view.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, rect.size.width, 0.0);
    CGContextConcatCTM(context, transform);
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
