//
//  ScaleAnimator.h
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ScaleAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/**
 动画开始位置的视图
 */
@property (nonatomic,strong) UIView *startView;

/**
 动画结束位置的视图
 */
@property (nonatomic,strong) UIView *endView;

/**
 用于转场时的缩放视图
 */
@property (nonatomic,strong) UIView *scaleView;

/**
 初始化

 @param startView 动画开始位置的视图
 @param endView 动画结束位置的视图
 @param scaleView 用于转场时的缩放视图
 @return 实例
 */
- (instancetype)initWithStartView:(UIView *)startView endView:(UIView *)endView scaleView:(UIView *)scaleView;

@end
