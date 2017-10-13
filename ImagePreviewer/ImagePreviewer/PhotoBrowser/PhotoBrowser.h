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

/// 实现本方法以返回图片数量
- (NSInteger)numberOfPhotosInPhotoBroswer:(PhotoBrowser *)photoBrowser;

/// 实现本方法以返回高质量图片的url。可选
- (NSURL *)photoBrowser:(PhotoBrowser *)photoBrowser highQualityUrlForIndex:(NSInteger)index;

/// 退出图片浏览器方法
- (void)photoBrowser:(PhotoBrowser *)photoBrowser dismissAtIndex:(NSInteger)index;

/// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
/// 比如你可以返回imageView，或整个cell
- (UIView *)photoBrowser:(PhotoBrowser *)photoBrowser thumbnailViewForIndex:(NSInteger)index;

@end

@interface PhotoBrowser : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic,weak) id <PhotoBrowserDelegate> delegate;

/// 左右两张图之间的间隙，默认 20
@property (nonatomic,assign) CGFloat photoSpacing;

/// 图片缩放模式，默认 scaleAspectFill
@property (nonatomic,assign) UIViewContentMode imageScaleMode;

/// 捏合手势放大图片时的最大允许比例，默认 2.0
@property (nonatomic,assign) CGFloat imageMaximumZoomScale;

/// 双击放大图片时的目标比例，默认 2.0
@property (nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;

/// 初始化构造器
- (instancetype)initWithPresentingVC:(UIViewController *)viewController delegate:(id<PhotoBrowserDelegate>)delegate;

/// 使用默认配置展示
- (void)showWithPresentingVC:(UIViewController *)viewControlelr delegate:(id<PhotoBrowserDelegate>)delegate index:(NSInteger)index;

/// 展示对应index的图片
- (void)showWithIndex:(NSInteger)index;

@end
