//
//  PhotoBrowserCell.h
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserCell;
@protocol PhotoBrowserCellDelegate <NSObject>

/**
 单击时回调
 
 @param cell PhotoBrowserCell
 */
- (void)photoBroswerCellDidSingleTap:(PhotoBrowserCell *_Nonnull)cell;

/**
 拖动时回调

 @param cell PhotoBrowserCell
 @param scale 缩放比例
 */
- (void)photoBroswerCell:(PhotoBrowserCell *_Nonnull)cell didPanScale:(CGFloat)scale;

/**
 长按时回调

 @param cell PhotoBrowserCell
 @param image 长按的图片
 */
- (void)photoBroswerCell:(PhotoBrowserCell *_Nonnull)cell didLongPressWith:(UIImage *_Nonnull)image;

@end

@interface PhotoBrowserCell : UICollectionViewCell

NS_ASSUME_NONNULL_BEGIN
@property (nonatomic,weak) id<PhotoBrowserCellDelegate> photoBroswerCellDelegate;
NS_ASSUME_NONNULL_END
/**
 图像加载视图
 */
@property (nonatomic,strong) UIImageView * _Nonnull imageView;

/**
 设置图片

 @param image 占位图或者本地图片
 @param url 网络资源
 */
- (void)setImageWithPlaceHolder:( UIImage * _Nonnull )image url:(NSString * _Nullable)url;

@end
