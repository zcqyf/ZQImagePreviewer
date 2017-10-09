//
//  ScaleAnimator.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ScaleAnimator.h"

@interface ScaleAnimator () 

@end

@implementation ScaleAnimator

- (instancetype)initWithStartView:(UIView *)startView endView:(UIView *)endView scaleView:(UIView *)scaleView {
    self.startView = startView;
    self.endView = endView;
    self.scaleView = scaleView;
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    //判断是present动画还是dismiss动画
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewKey];
    if (fromVC && toVC) {
        
        BOOL presentation = (toVC.presentingViewController == fromVC);
        
        //dismiss转场，需要把presentedView隐藏，只显示scaleView
        UIView *presentedView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        if (!presentation && presentedView) {
            [presentedView setHidden:YES];
        }
        
        //取转场中介容器
        UIView *containerView = transitionContext.containerView;
        //求缩放视图的起始和结束frame
        UIView *startView = self.startView;
        UIView *endView = self.endView;
        UIView *scaleView = self.scaleView;
        if (!startView || !scaleView) {
            return;
        }
        
        CGRect startFrame = [startView convertRect:startView.bounds toView:containerView];
        
        //暂不求 endFrame
        CGRect endFrame = CGRectZero;
        CGFloat endAlpah = 0.0;
        
        if (endView) {
            // 当前正在显示视图的前一个页面关联视图已经存在，此时分两种情况
            // 1、该视图显示在屏幕内，作scale动画
            // 2、该视图不显示在屏幕内，作fade动画
            CGRect relativeFrame = [endView convertRect:endView.bounds toView:nil];
            CGRect keyWindowBounds = [UIScreen.mainScreen bounds];
            if (CGRectIntersectsRect(keyWindowBounds, relativeFrame)) {
                // 在屏幕内，求endFrame，让其缩放
                endAlpah = 1.0;
                endFrame = [endView convertRect:endView.bounds toView:containerView];
            }
        }
        
        scaleView.frame = startFrame;
        [containerView addSubview:scaleView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            scaleView.alpha = endAlpah;
            scaleView.frame = endFrame;
        } completion:^(BOOL finished) {
            UIView *prewsentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
            //presentation转场，需要把目标视图添加到视图栈
            if (presentation && prewsentedView) {
                [containerView addSubview:presentedView];
            }
            [scaleView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}


@end
