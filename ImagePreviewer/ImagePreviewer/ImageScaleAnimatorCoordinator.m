//
//  ImageScaleAnimatorCoordinator.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/12.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ImageScaleAnimatorCoordinator.h"

@implementation ImageScaleAnimatorCoordinator

- (UIView *)maskView {
    
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor blackColor];
    }
//    UIView *view = [UIView new];
//    view.backgroundColor = [UIColor blackColor];
    
    return _maskView;
}

- (void)updateCurrentHiddenView:(UIView *)view {
    [_currentHiddenView setHidden:NO];
    _currentHiddenView = view;
    [view setHidden:YES];
}

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
