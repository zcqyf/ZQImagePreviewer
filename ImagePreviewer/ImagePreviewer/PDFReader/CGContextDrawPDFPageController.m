//
//  CGContextDrawPDFPageController.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "CGContextDrawPDFPageController.h"
#import "CGContextDrawPDFView.h"

@interface CGContextDrawPDFPageController () <UIScrollViewDelegate>

@property (nonatomic,strong) CGContextDrawPDFView *pdfView;

@end

@implementation CGContextDrawPDFPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    [self setupUI];
}

- (void)setupUI {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 3.0;
    scrollView.zoomScale = 1.0;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    //  iOS 11
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    _pdfView = [[CGContextDrawPDFView alloc] initWithFrame:self.view.bounds atPage:self.pageNum withPDFDoc:self.pdfDocument];
    _pdfView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:_pdfView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _pdfView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    [_pdfView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
