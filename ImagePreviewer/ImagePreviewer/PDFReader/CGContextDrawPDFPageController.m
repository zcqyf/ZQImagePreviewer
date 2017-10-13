//
//  CGContextDrawPDFPageController.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "CGContextDrawPDFPageController.h"
#import "CGContextDrawPDFView.h"

@interface CGContextDrawPDFPageController ()

@end

@implementation CGContextDrawPDFPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI {
    CGContextDrawPDFView *pdfView = [[CGContextDrawPDFView alloc] initWithFrame:self.view.bounds atPage:self.pageNO withPDFDoc:self.pdfDocument];
    pdfView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pdfView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
