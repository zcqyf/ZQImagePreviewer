//
//  CGContextDrawPDFPageModel.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIPageViewController.h>

@class CGContextDrawPDFPageController;
@interface CGContextDrawPDFPageModel : NSObject <UIPageViewControllerDataSource>
{
    CGPDFDocumentRef pdfDocument;
}

/// 根据 CGPDFDocumentRef 初始化
- (instancetype)initWithPDFDocument:(CGPDFDocumentRef)pdfDoc;

/// 获取对应 index 的 CGContextDrawPDFPageController
- (CGContextDrawPDFPageController *)viewControllerAtIndex:(NSUInteger)index;

/// 返回 CGContextDrawPDFPageController 对应的 index
- (NSUInteger)indexOfViewController:(CGContextDrawPDFPageController *)viewController;

@end
