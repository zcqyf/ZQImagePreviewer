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
 
 */
@property (nonatomic,weak) id<PhotoBroswerDelegate> photoBroswerDelegate;

/**
 左右两张图之间的间隙
 */
@property (nonatomic,assign) CGFloat photoSpacing;

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
