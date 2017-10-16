//
//  CGContextDrawPDFPageController.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGContextDrawPDFPageController : UIViewController

/// CGPDFDocumentRef pdfDocument;
@property (nonatomic,assign) CGPDFDocumentRef pdfDocument;

/// page
@property (nonatomic,assign) long pageNum;

@end
