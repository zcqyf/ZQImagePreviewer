//
//  ImageScaleAnimator.m
//  VCTransitionTest
//
//  Created by qing on 2017/10/12.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ImageScaleAnimator.h"

@interface ImageScaleAnimator ()

@property (nonatomic,strong) UIView *startView;

@property (nonatomic,strong) UIView *scaleView;

@property (nonatomic,strong) UIView *endView;

@property (nonatomic,assign) BOOL isPresented;

@end

@implementation ImageScaleAnimator

- (instancetype)initWithStartView:(UIView *)startView scaleView:(UIView *)scaleView endView:(UIView *)endView isPresented:(BOOL)isPresented {
    self = [super init];
    if (self) {
        self.startView = startView;
        self.scaleView = scaleView;
        self.endView = endView;
        self.isPresented = isPresented;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [self transitionBegan:transitionContext];
}

- (void)transitionBegan:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    //  转场容器
    UIView *containerView = [transitionContext containerView];
    //  dismiss，需要隐藏
    if (!_isPresented) {
        [fromView setHidden:YES];
    }
    
    CGRect startFrame = [self.startView convertRect:self.startView.bounds toView:containerView];
    
    CGRect endFrame = startFrame;
    CGFloat endAlpha = 0;
    
    CGRect relativeFrame = [self.endView convertRect:self.endView.bounds toView:nil];
    CGRect keyWindowBounds = [UIScreen.mainScreen bounds];
    if (CGRectIntersectsRect(relativeFrame, keyWindowBounds)) {
        //在屏幕内，求endFrame，让其缩放
        endAlpha = 1.0;
        endFrame = [self.endView convertRect:self.endView.bounds toView:containerView];
    }
    
    self.scaleView.frame = startFrame;
    [containerView addSubview:self.scaleView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.scaleView.alpha = endAlpha;
        self.scaleView.frame = endFrame;
        toView.alpha = 1;
    } completion:^(BOOL finished) {
        if (_isPresented) {
            [containerView addSubview:toView];
        }
        [self.scaleView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
