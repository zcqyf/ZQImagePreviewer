//
//  PhotoBrowserProgressView.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "PhotoBrowserProgressView.h"

@interface PhotoBrowserProgressView ()

/**
 外边界
 */
@property (nonatomic,strong) CAShapeLayer *circleLayer;

/**
 扇形区
 */
@property (nonatomic,strong) CAShapeLayer *fanshapedLayer;

@end

@implementation PhotoBrowserProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
            CGSize size = CGSizeMake(50, 50);
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
        }
        [self setupUI];
        _progress = 0;
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    CGColorRef strokeColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    
    _circleLayer = [CAShapeLayer new];
    _circleLayer.strokeColor = strokeColor;
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.path = [self makeCirclePath].CGPath;
    [self.layer addSublayer:_circleLayer];
    
    _fanshapedLayer = [CAShapeLayer new];
    _fanshapedLayer.fillColor = strokeColor;
    [self.layer addSublayer:_fanshapedLayer];
}

#pragma mark - getter and setter
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _fanshapedLayer.path = [self makeProgressPath:_progress].CGPath;
}

- (UIBezierPath *)makeCirclePath {
    
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:25 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.lineWidth = 2;
    
    return path;
}

/**
 根据进度绘制
 */
- (UIBezierPath *)makeProgressPath:(CGFloat)progress {
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetMidY(self.bounds) - 2.5;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds), center.y - radius)];
    [path addArcWithCenter:center radius:radius startAngle:-(M_PI / 2) endAngle:(-(M_PI / 2) + M_PI * 2 * progress) clockwise:YES];
    [path closePath];
    path.lineWidth = 1;

    return path;
}



@end
