//
//  CGContextDrawPDFReaderController.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "CGContextDrawPDFReaderController.h"
#import "CGContextDrawPDFPageController.h"

@interface CGContextDrawPDFReaderController ()

@end

@implementation CGContextDrawPDFReaderController
@synthesize titleText, fileName;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupPDFPageModel];
    [self setupPageViewController];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.titleText;
}

/// 根据 fileName 创建pdfPageModel
- (void)setupPDFPageModel {
    //  CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("test.pdf"), NULL, NULL);
    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)self.fileName, NULL, NULL);
    //  创建CGPDFDocument
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    CFRelease(pdfURL);
    pdfPageModal = [[CGContextDrawPDFPageModel alloc] initWithPDFDocument:pdfDocument];
}

/// 设置 pageViewController
- (void)setupPageViewController {
    //  UIPageViewControllerSpineLocationMin 单页显示
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey:UIPageViewControllerOptionSpineLocationKey];
    //初始化UIPageViewController，UIPageViewControllerTransitionStylePageCurl翻页效果，UIPageViewControllerNavigationOrientationHorizontal水平方向翻页
    pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    //  承载PDF每页内容的控制器
    CGContextDrawPDFPageController *initialViewController = [pdfPageModal viewControllerAtIndex:1];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    //  设置UIPageViewController的数据源
    [pageController setDataSource:pdfPageModal];
    
    //  设置正反面都有文字 TODO 存在问题
    pageController.doubleSided = NO;
    
    //  设置pageViewCtrl的子控制器
    [pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:^(BOOL finished) {
        
    }];
    [self addChildViewController:pageController];
    [self.view addSubview:pageController.view];
    //  当我们向我们的视图控制器容器（就是父视图控制器，它调用addChildViewController方法加入子视图控制器，它就成为了视图控制器的容器）中添加（或者删除）子视图控制器后，必须调用该方法，告诉iOS，已经完成添加（或删除）子控制器的操作。
    [pageController didMoveToParentViewController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
