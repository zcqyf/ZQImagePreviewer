//
//  CGContextDrawPDFView.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGContextDrawPDFView : UIView {
    /// PDF文件环境
    CGPDFDocumentRef pdfDocument;
    /// 页码
    long pageNum;
}

/// 根据 page 和 CGPDFDocumentRef 初始化
- (instancetype)initWithFrame:(CGRect)frame atPage:(long)index withPDFDoc:(CGPDFDocumentRef)pdfDoc;

@end
