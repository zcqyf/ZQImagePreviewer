//
//  CGContextDrawPDFView.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGContextDrawPDFView : UIView {
    CGPDFDocumentRef pdfDocument;
    long pageNO;
}

- (instancetype)initWithFrame:(CGRect)frame atPage:(long)index withPDFDoc:(CGPDFDocumentRef)pdfDoc;

@end