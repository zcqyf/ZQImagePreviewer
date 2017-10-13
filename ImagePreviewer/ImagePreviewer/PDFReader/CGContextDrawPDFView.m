//
//  CGContextDrawPDFView.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/13.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "CGContextDrawPDFView.h"

@implementation CGContextDrawPDFView

- (instancetype)initWithFrame:(CGRect)frame atPage:(long)index withPDFDoc:(CGPDFDocumentRef)pdfDoc {
    self = [super initWithFrame:frame];
    if (self) {
        pageNO = index;
        pdfDocument = pdfDoc;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //  TODO 成员变量属性区别
    [self drawInContext:UIGraphicsGetCurrentContext() atPageNO:pageNO];
}

- (void)drawInContext:(CGContextRef)context atPageNO:(long)page_no {
    //  Quartz坐标系和UIView坐标系不一样所致，调整坐标系，使PDF正立
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (pageNO == 0) {
        pageNO = 1;
    }
    
    //  获取指定页的pdf文档
    CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, pageNO);
    //  创建一个仿射变换，该变换基于将PDF页的Box映射到指定的矩形中
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, self.bounds, 0, YES);
    CGContextConcatCTM(context, pdfTransform);
    //  将PDF绘制到上下文中
    CGContextDrawPDFPage(context, page);
}


@end
