//
//  PhotoBrowser.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/10.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowser;
@protocol PhotoBrowserDelegate <NSObject>


/**
 退出图片浏览器方法

 @param photoBrowser PhotoBrowser
 @param index 抛出对应图片index
 */
- (void)photoBrowser:(PhotoBrowser *)photoBrowser dismissAtIndex:(NSInteger)index;

/// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
/// 比如你可以返回imageView，或整个cell
- (UIView *)photoBrowser:(PhotoBrowser *)photoBrowser thumbnailViewForIndex:(NSInteger)index;

@end

@interface PhotoBrowser : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic,strong) UIImageView *endImageView;

@property (nonatomic,weak) id <PhotoBrowserDelegate> delegate;

/// 本VC的presentingViewController
@property (nonatomic,strong) UIViewController *presentingVC;


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
