//
//  ModalAnimationDelegate.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/11.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ModalAnimationDelegate.h"
#import "PhotoBrowser.h"


#import "ViewController.h"
#import "CollectionViewCell.h"
#import "PBCollectionViewCell.h"

@interface ModalAnimationDelegate ()

@property (nonatomic,assign) BOOL isPresentAnimation;

@end

@implementation ModalAnimationDelegate

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _isPresentAnimation = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _isPresentAnimation = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _isPresentAnimation ? [self presentViewAnimation:transitionContext] : [self dismissViewAnimation:transitionContext];
}

- (void)presentViewAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    //  过渡view
    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    //  容器view
    UIView *containView = transitionContext.containerView;
    if (!destinationView) {
        return;
    }
    //  过渡view添加到容器view上
    [containView addSubview:destinationView];
    //  目标控制器
    PhotoBrowser *destinationController = (PhotoBrowser *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSInteger index = destinationController.currentIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    //  当前跳转的控制器
    ViewController *collectionViewController = (ViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UICollectionView *currentCollectionView = collectionViewController.collectionView;
    //  当前选中的cell
    CollectionViewCell *selectedCell = (CollectionViewCell *)[currentCollectionView cellForItemAtIndexPath:indexPath];
    //  新建一个imageView添加到目标view之上，作为动画view
    UIImageView *animateView = [UIImageView new];
    animateView.image = selectedCell.imageView.image;
    animateView.contentMode = UIViewContentModeScaleAspectFill;
    animateView.clipsToBounds = YES;
    //  被选中的cell到目标view上的坐标转换
    CGRect originFrame = [currentCollectionView convertRect:selectedCell.frame toView:[UIApplication.sharedApplication keyWindow]];
    animateView.frame = originFrame;
    [containView addSubview:animateView];
    CGRect endFrame = [self convertImageFrameToFullScreenFrame:selectedCell.imageView.image];
    destinationView.alpha = 0;
    //  过渡动画
    [UIView animateWithDuration:1 animations:^{
        animateView.frame = endFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [UIView animateWithDuration:0.5 animations:^{
            destinationView.alpha = 1;
        } completion:^(BOOL finished) {
            [animateView removeFromSuperview];
        }];
    }];
    
}

- (void)dismissViewAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *transitionView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *containView = transitionContext.containerView;
    //  取出modal出来的控制器
    PhotoBrowser *destinationController = (PhotoBrowser *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //  取出当前显示的collectionView
    UICollectionView *presentView = destinationController.collectionView;
    //  取出控制器当前显示的cell
    PBCollectionViewCell *dismissCell = presentView.visibleCells.firstObject;
    //  新建过渡动画imageView
    UIImageView *animateView = [UIImageView new];
    animateView.contentMode = UIViewContentModeScaleAspectFill;
    animateView.clipsToBounds = YES;
    //  获取当前显示cell的image
    animateView.image = dismissCell.imgView.image;
    //  获取当前显示cell在window中的frame
    animateView.frame = dismissCell.imgView.frame;
    [containView addSubview:animateView];
    //  动画最后停止的frame
    NSIndexPath *indexPath = [presentView indexPathForCell:dismissCell];
    //  取出要返回的控制器view
    UICollectionView *originView = ((ViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]).collectionView;
    CollectionViewCell *originCell = (CollectionViewCell *)[originView cellForItemAtIndexPath:indexPath];
    if (!originCell) {
        [originView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        [originView layoutIfNeeded];
        return;
    }
    CGRect originFrame = [originView convertRect:originCell.frame toView:[UIApplication.sharedApplication keyWindow]];
    [UIView animateWithDuration:1 animations:^{
        animateView.frame = originFrame;
        transitionView.alpha = 0;
    } completion:^(BOOL finished) {
        [animateView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (CGRect)convertImageFrameToFullScreenFrame:(UIImage *)image {
    if (!image) {
        return CGRectZero;
    }
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = w * image.size.height / image.size.width;
    CGFloat x = 0;
    CGFloat y = (UIScreen.mainScreen.bounds.size.height - h) * 0.5;
    return CGRectMake(x, y, w, h);
}

@end



























