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

/// 单击时回调
- (void)photoBrowserCellDidSingleTap:(PBCollectionViewCell *)cell;

/// 长按时回调
- (void)photoBroswerCell:(PBCollectionViewCell *)cell didLongPressWith:(UIImage *)image;

/// 拖动时回调   TODO 待完善
- (void)photoBroswerCell:(PBCollectionViewCell *)cell didPanScale:(CGFloat)scale;

@end

@interface PBCollectionViewCell : UICollectionViewCell

/// 图片容器
@property (nonatomic,strong) UIImageView *imgView;

///  图片url
@property (nonatomic,strong) NSURL *imgUrl;

@property (nonatomic,weak) id <PBCollectionViewCellDelegate> delegate;

/// 
@property (nonatomic,assign) CGFloat imageMaximumZoomScale;

/**
 双击放大图片时的目标比例，默认2.0
 */
@property (nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;

@end
