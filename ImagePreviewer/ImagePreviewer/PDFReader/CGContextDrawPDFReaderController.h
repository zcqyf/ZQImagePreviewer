//
//  CGContextDrawPDFReaderController.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CGContextDrawPDFPageModel.h"

@interface CGContextDrawPDFReaderController : UIViewController
{
    UIPageViewController *pageViewCtrl;
    CGContextDrawPDFPageModel *pdfPageModal;
}

@property (nonatomic,copy) NSString *titleText, *fileName;

@end
