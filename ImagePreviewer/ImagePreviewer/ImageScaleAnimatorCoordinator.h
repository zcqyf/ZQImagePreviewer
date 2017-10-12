//
//  ImageScaleAnimatorCoordinator.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/12.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScaleAnimatorCoordinator : UIPresentationController

/// 动画结束后需要隐藏的view
@property (nonatomic,strong) UIView *currentHiddenView;

/// 蒙板
@property (nonatomic,strong) UIView *maskView;

/// 更新动画结束后需要隐藏的view
- (void)updateCurrentHiddenView:(UIView *)view;

@end
