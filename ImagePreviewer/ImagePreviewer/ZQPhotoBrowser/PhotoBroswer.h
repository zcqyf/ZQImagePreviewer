//
//  PhotoBroswer.h
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoBroswerDelegate.h"

@interface PhotoBroswer : UIViewController

/**
 实现了PhotoBrowserDelegate协议的对象
 */
@property (nonatomic,weak) id<PhotoBroswerDelegate> photoBroswerDelegate;

/**
 实现了PhotoBrowserPageControlDelegate协议的对象
 */
@property (nonatomic,weak) id<PhotoBroswerPageControlDelegate> pageControlDelegate;

/**
 左右两张图之间的间隙，默认 30
 */
@property (nonatomic,assign) CGFloat photoSpacing;

/**
 图片缩放模式，默认 scaleAspectFill
 */
@property (nonatomic,assign) UIViewContentMode imageScaleMode;

/**
 捏合手势放大图片时的最大允许比例，默认 2.0
 */
@property (nonatomic,assign) CGFloat imageMaximumZoomScale;

/**
 双击放大图片时的目标比例，默认 2.0
 */
@property (nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;

/**
 外露接口，展示图片浏览器
 */
- (void)show:(NSInteger)index;

/**
 初始化方法
 
 @param viewController 用于present
 @return PhotoBroswer实例
 */
- (instancetype)initWithPresentingVC:(UIViewController *)viewController delegate:(id<PhotoBroswerDelegate>)delegate;

/**
 初始化 + show
 */
- (void)showWithPresentingVC:(UIViewController *)viewControlelr delegate:(id<PhotoBroswerDelegate>)delegate index:(NSInteger)index;

@end
