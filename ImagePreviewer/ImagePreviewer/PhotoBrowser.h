//
//  PhotoBrowser.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/10.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowser : UIViewController <UIViewControllerTransitioningDelegate>

/**
 横向容器
 */
@property (nonatomic,strong) UICollectionView *collectionView;

/**
 URL 数组
 */
@property (nonatomic,copy) NSArray *imageUrls;

/**
 当前浏览图片的 index
 */
@property (nonatomic,assign) NSInteger currentIndex;

/**
 左右两张图之间的间隙，默认 20
 */
@property (nonatomic,assign) CGFloat photoSpacing;

/**
 图片缩放模式，默认 scaleAspectFill
 */
@property (nonatomic,assign) UIViewContentMode imageScaleMode;

/**
 本VC的presentingViewController
 */
@property (nonatomic,strong) UIViewController *presentingVC;

/**
 捏合手势放大图片时的最大允许比例，默认 2.0
 */
@property (nonatomic,assign) CGFloat imageMaximumZoomScale;

/**
 双击放大图片时的目标比例，默认 2.0
 */
@property (nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;

/**
 展示对应index的图片
 */
- (void)showWithIndex:(NSInteger)index;

@end
