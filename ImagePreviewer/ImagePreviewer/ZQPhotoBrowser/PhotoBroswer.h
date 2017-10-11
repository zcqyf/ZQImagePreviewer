//
//  PhotoBroswer.h
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBroswer;
@protocol PhotoBroswerDelegate <NSObject>
/// 实现本方法以返回图片数量
- (NSInteger)numberOfPhotosInPhotoBroswer:(PhotoBroswer *)photoBrowser;

/// 实现本方法以返回默认图片、缩略图或占位图
- (UIImage *)photoBrowser:(PhotoBroswer *)photoBrowser thumbnailImageForIndex:(NSInteger)index;

/// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
/// 比如你可以返回imageView，或整个cell
- (UIView *)photoBrowser:(PhotoBroswer *)photoBrowser thumbnailViewForIndex:(NSInteger)index;

@optional
/// 实现本方法以返回高质量图片的url。可选
- (NSURL *)photoBrowser:(PhotoBroswer *)photoBrowser highQualityUrlForIndex:(NSInteger)index;

/// 实现本方法以返回原图url。可选
- (NSURL *)photoBrowser:(PhotoBroswer *)photoBrowser rawUrlForIndex:(NSInteger)index;

/// 长按时回调。可选
- (void)photoBrowser:(PhotoBroswer *)photoBrowser didLongPressForIndex:(NSInteger)index image:(UIImage *)image;

@end

@protocol PhotoBroswerPageControlDelegate <NSObject>
/// 总图片数/页数
@property (nonatomic,assign) NSInteger numberOfPages;

/// 取PageControl，只会取一次
- (UIView *)pageControlOfPhotoBrowser:(PhotoBroswer *)photoBrowser;

/// 添加到父视图上时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didMoveTo:(UIView *)superView;

/// 让pageControl布局时调用
- (void)photoBrowserPageControl:(UIView *)pageControl needLayoutIn:(UIView *)superView;

/// 页码变更时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didChangedCurrentPage:(NSInteger)currentPage;

@end

@interface PhotoBroswer : UIViewController

// MARK: -  公开属性
/// 实现了PhotoBrowserDelegate协议的对象
@property (nonatomic,weak) id <PhotoBroswerDelegate> photoBroswerDelegate;

/// 实现了PhotoBrowserPageControlDelegate协议的对象
@property (nonatomic,weak) id <PhotoBroswerPageControlDelegate> pageControlDelegate;

/// 左右两张图之间的间隙
@property (nonatomic,assign) CGFloat photoSpacing;

/// 图片缩放模式
@property (nonatomic,assign) UIViewContentMode imageScaleMode;

/// 捏合手势放大图片时的最大允许比例
@property (nonatomic,assign) CGFloat imageMaximumZoomScale;

/// 双击放大图片时的目标比例
@property (nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;

/// 展示，传入图片序号，从0开始
- (void)show:(NSInteger)index;

// MARK: - 公开方法
/// 初始化，传入用于present出本VC的VC，以及实现了PhotoBrowserDelegate协议的对象
- (instancetype)initWithPresentingVC:(UIViewController *)viewController delegate:(id<PhotoBroswerDelegate>)delegate;

/// 便利的展示方法，合并init和show两个步骤
- (void)showWithPresentingVC:(UIViewController *)viewControlelr delegate:(id<PhotoBroswerDelegate>)delegate index:(NSInteger)index;

@end
