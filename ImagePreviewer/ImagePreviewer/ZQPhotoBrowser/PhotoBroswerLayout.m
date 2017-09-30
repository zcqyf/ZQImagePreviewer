//
//  PhotoBroswerLayout.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "PhotoBroswerLayout.h"

@interface PhotoBroswerLayout ()

/**
 一页宽度，算上空隙
 */
@property (nonatomic,assign) CGFloat pageWidth;

/**
 上次页码
 */
@property (nonatomic,assign) CGFloat lastPage;

/**
 最小页码
 */
@property (nonatomic,assign) CGFloat minPage;

/**
 最大页码
 */
@property (nonatomic,assign) CGFloat maxPage;

@end

@implementation PhotoBroswerLayout

/**
 重写 init

 @return layout 实例
 */
- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _minPage = 0;
    }
    return self;
}

#pragma mark - lazy
- (CGFloat)pageWidth {
//    if (!_pageWidth) {
//        _pageWidth = self.itemSize.width + self.minimumLineSpacing;
//    }
//    return _pageWidth;
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGFloat)lastPage {
    if (!self.collectionView.contentOffset.x) {
        return 0;
    } else {
        return round(self.collectionView.contentOffset.x/self.pageWidth);
    }
}

- (CGFloat)maxPage {
//    if (!_maxPage) {
//        CGFloat contentWidth = self.collectionView.contentSize.width;
//        contentWidth += self.minimumLineSpacing;
//        _maxPage = contentWidth / self.pageWidth - 1;
//    }
//    return _maxPage;
    CGFloat contentWidth = self.collectionView.contentSize.width;
    if (!contentWidth) {
        return 0;
    } else {
        contentWidth += self.minimumLineSpacing;
        return contentWidth / self.pageWidth - 1;
    }
}

//调整scroll停下来的位置
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    //页码
    CGFloat page = round(proposedContentOffset.x / self.pageWidth);
    //处理轻微滑动
    if (velocity.x > 0.2) {
        page += 1;
    } else if (velocity.x < -0.2) {
        page -= 1;
    }
    
    //一次滑动不允许超过一页
    if (page > self.lastPage + 1) {
        page = self.lastPage + 1;
    } else if (page < self.lastPage - 1) {
        page = self.lastPage - 1;
    }
    
    if (page > self.maxPage) {
        page = self.maxPage;
    } else if (page < self.minPage) {
        page = self.minPage;
    }
    
    self.lastPage = page;
    
    return CGPointMake(page * self.pageWidth, 0);
}

@end



























