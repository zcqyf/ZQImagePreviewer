//
//  ImageScaleAnimator.h
//  VCTransitionTest
//
//  Created by qing on 2017/10/12.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScaleAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/**
 初始化方法

 @param startView 初始view
 @param scaleView 动画view
 @param endView 终点view
 @return ImageScaleAnimator 实例
 */
- (instancetype)initWithStartView:(UIView *)startView scaleView:(UIView *)scaleView endView:(UIView *)endView isPresented:(BOOL)isPresented;

@end
