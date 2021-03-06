//
//  CGContextDrawPDFPageModel.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "CGContextDrawPDFPageModel.h"
#import "CGContextDrawPDFPageController.h"
#import "BackViewController.h"

@interface CGContextDrawPDFPageModel ()

/// 当前的vc
@property (nonatomic,strong) UIViewController *currentViewController;

@end

@implementation CGContextDrawPDFPageModel

- (instancetype)initWithPDFDocument:(CGPDFDocumentRef)pdfDoc {
    self = [super init];
    if (self) {
        pdfDocument = pdfDoc;
    }
    return self;
}

- (CGContextDrawPDFPageController *)viewControllerAtIndex:(NSUInteger)index {
    // 总页数
    long pageSum = CGPDFDocumentGetNumberOfPages(pdfDocument);
    if (pageSum == 0 || index >= pageSum + 1) {
        return nil;
    }
    //  Create a new view controller and pass suitable data.
    CGContextDrawPDFPageController *pageController = [CGContextDrawPDFPageController new];
    pageController.pdfDocument = pdfDocument;
    pageController.pageNum = index;
    
    return pageController;
}

- (NSUInteger)indexOfViewController:(CGContextDrawPDFPageController *)viewController {
    return viewController.pageNum;
}

#pragma mark 如果要每页的背面显示与正面相同的风格，而不是默认的白，需要设置pageController的doubleSize属性为YES，同时在下面的两个代理方法中设置BackViewController
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
//    if ([viewController isKindOfClass:[CGContextDrawPDFPageController class]]) {
//        self.currentViewController = viewController;
//
//        BackViewController *backViewController = [BackViewController new];
//        [backViewController updateWithViewController:viewController];
//        return backViewController;
//    }
    
    self.currentViewController = viewController;
    
    //  self.currentViewController保存的是后一个CGContextDrawPDFPageController，如果直接用viewController实际指的是backViewController，而其没有indexOfViewController：等方法程序会崩掉。
    NSUInteger index = [self indexOfViewController:(CGContextDrawPDFPageController *)self.currentViewController];
    if ((index == 1) || (index == NSNotFound)) {
        return nil;
    }
    index --;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
//    if ([viewController isKindOfClass:[CGContextDrawPDFPageController class]]) {
//        self.currentViewController = viewController;
//
//        BackViewController *backViewController = [BackViewController new];
//        [backViewController updateWithViewController:viewController];
//        return backViewController;
//    }
    
    self.currentViewController = viewController;
    
    //  self.currentViewController保存的是前一个CGContextDrawPDFPageController，如果直接用viewController实际指的是backViewController，而其没有indexOfViewController：等方法程序会崩掉。
    NSUInteger index = [self indexOfViewController: (CGContextDrawPDFPageController *)self.currentViewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    //获取pdf文档的页数
    long pageSum = CGPDFDocumentGetNumberOfPages(pdfDocument);
    if (index >= pageSum+1) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end




