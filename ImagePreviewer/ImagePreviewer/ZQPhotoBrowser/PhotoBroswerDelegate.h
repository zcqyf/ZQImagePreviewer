//
//  PhotoBroswerDelegate.h
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoBroswer;
@protocol PhotoBroswerDelegate <NSObject>

/**
 实现本方法以返回图片数量
 
 @param photoBroswer 图片浏览器
 @return 图片数量
 */
- (NSInteger)numberOfPhotosInPhotoBroswer:(PhotoBroswer *)photoBroswer;

/**
 实现本方法以返回默认图片，缩略图或占位图
 
 @param photoBroswer 图片浏览器
 @param index 对应哪一张图片
 @return 返回图片
 */
- (UIImage *)photoBroswer:(PhotoBroswer *)photoBroswer thumbnailImageForIndex:(NSInteger)index;

/**
 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
 */
- (UIView *)photoBroswer:(PhotoBroswer *)photoBroswer thumbnailViewForIndex:(NSInteger)index;

@optional

/**
 实现本方法返回高质量图片
 
 @param photoBroswer 图片浏览器
 @param index 对应哪一张图片
 @return 返回图片
 */
- (UIImage *)photoBroswer:(PhotoBroswer *)photoBroswer highQualityImageForIndex:(NSInteger)index;

/**
 实现本方法以返回图片url
 
 @param photoBroswer 图片浏览器
 @param index 对应哪一张图片
 @return 返回 urlstring
 */
- (NSString *)photoBroswer:(PhotoBroswer *)photoBroswer highQualityUrlStringForIndex:(NSInteger)index;

@end
