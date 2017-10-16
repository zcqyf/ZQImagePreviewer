//
//  CGContextDrawPDFView.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "CGContextDrawPDFView.h"

@interface CGContextDrawPDFView () 

@end

@implementation CGContextDrawPDFView

- (instancetype)initWithFrame:(CGRect)frame atPage:(long)index withPDFDoc:(CGPDFDocumentRef)pdfDoc {
    self = [super initWithFrame:frame];
    if (self) {
        pageNum = index;
        pdfDocument = pdfDoc;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //  获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //  Quartz坐标系和UIView坐标系不一样所致，调整坐标系，使PDF正立
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (pageNum == 0) {
        pageNum = 1;
    }
    
    //  获取指定页的pdf文档
    CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, pageNum);
    //  创建一个仿射变换，该变换基于将PDF页的Box映射到指定的矩形中
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, self.bounds, 0, YES);
    CGContextConcatCTM(context, pdfTransform);
    //  将PDF绘制到上下文中
    CGContextDrawPDFPage(context, page);
}

@end
