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

- (instancetype)initWithPDFDocument:(CGPDFDocumentRef)pdfDocument;

- (CGContextDrawPDFPageController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(CGContextDrawPDFPageController *)viewController;

@end
