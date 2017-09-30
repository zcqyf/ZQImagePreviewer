//
//  ScaleAnimatorCoordinator.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ScaleAnimatorCoordinator.h"

@interface ScaleAnimatorCoordinator ()

@end

@implementation ScaleAnimatorCoordinator

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    
    UIView *containerView = self.containerView;
    if (!containerView) {
        return;
    }
    
    [containerView addSubview:self.maskView];
    _maskView.frame = containerView.bounds;
    _maskView.alpha = 0;
    [self.currentHiddenView setHidden:YES];
    // TODO
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.alpha = 1;
    } completion:nil];

}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    [self.currentHiddenView setHidden:YES];
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.currentHiddenView setHidden:NO];
    }];
}

@end
