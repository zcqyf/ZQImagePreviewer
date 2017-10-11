//
//  PBCollectionViewCell.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/10.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCollectionViewCell;
@protocol PBCollectionViewCellDelegate <NSObject>

/**
 单击时回调
 
 @param cell PhotoBrowserCell
 */
- (void)photoBrowserCellDidSingleTap:(PBCollectionViewCell *)cell;

/**
 长按时回调
 
 @param cell PhotoBrowserCell
 @param image 长按的图片
 */
- (void)photoBroswerCell:(PBCollectionViewCell *)cell didLongPressWith:(UIImage *)image;

@end

@interface PBCollectionViewCell : UICollectionViewCell

/**
 图片容器
 */
@property (nonatomic,strong) UIImageView *imgView;

/**
 图片url
 */
@property (nonatomic,strong) NSString *imgUrl;

@property (nonatomic,weak) id <PBCollectionViewCellDelegate> delegate;

/**
 捏合手势放大图片时的最大允许比例, 默认2.0
 */
@property (nonatomic,assign) CGFloat imageMaximumZoomScale;

/**
 双击放大图片时的目标比例，默认2.0
 */
@property (nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;

@end
