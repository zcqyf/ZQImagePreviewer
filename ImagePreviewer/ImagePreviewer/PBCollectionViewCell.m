//
//  PBCollectionViewCell.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/10.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "PBCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotoBrowserProgressView.h"

@interface PBCollectionViewCell () <UIScrollViewDelegate>



/**
 放大缩小容器
 */
@property (nonatomic,strong) UIScrollView *scrollView;

/**
 自定义进度显示view
 */
@property (nonatomic,strong) PhotoBrowserProgressView *progressView;

/**
 计算contentSize应处于的中心位置
 */
@property (nonatomic,assign) CGPoint centerOfContentSize;

/**
 取图片适屏size
 */
@property (nonatomic,assign) CGSize fitSize;

/**
 取图片适屏frame
 */
@property (nonatomic,assign) CGRect fitFrame;

@end

@implementation PBCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageMaximumZoomScale = 2.0;
        _imageZoomScaleForDoubleTap = 2.0;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 2.0;
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [self.contentView addSubview:_scrollView];
        
        _imgView = [UIImageView new];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [_scrollView addSubview:_imgView];
        
        _progressView = [PhotoBrowserProgressView new];
        [self.contentView addSubview:_progressView];
        [_progressView setHidden:YES];
        
        //长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.contentView addGestureRecognizer:longPress];
        //双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTap];
        //单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self.contentView addGestureRecognizer:singleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

//  响应长按
- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan && (self.delegate && [self.delegate respondsToSelector:@selector(photoBroswerCell:didLongPressWith:)]) && self.imgView.image) {
        [self.delegate photoBroswerCell:self didLongPressWith:self.imgView.image];
    }
}

//  响应双击
- (void)doubleTap:(UITapGestureRecognizer *)sender {
    // 如果当前没有任何缩放，则放大到目标比例
    // 否则重置到原比例
    if (_scrollView.zoomScale == 1.0) {
        // 以点击的位置为中心，放大
        CGPoint pointInView = [sender locationInView:_imgView];
        CGFloat w = _scrollView.bounds.size.width / _imageZoomScaleForDoubleTap;
        CGFloat h = _scrollView.bounds.size.height / _imageZoomScaleForDoubleTap;
        CGFloat x = pointInView.x - (w / 2.0);
        CGFloat y = pointInView.y - (h / 2.0);
        [_scrollView zoomToRect:CGRectMake(x, y, w, h) animated:YES];
    } else {
        [_scrollView setZoomScale:1.0 animated:YES];
    }
}

//  响应单击
- (void)singleTap:(UITapGestureRecognizer *)sender {
    [self singleTapAction];
}

- (void)singleTapAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserCellDidSingleTap:)]) {
        [self.delegate photoBrowserCellDidSingleTap:self];
    }
}

#pragma mark - getter and setter
- (void)setImageMaximumZoomScale:(CGFloat)imageMaximumZoomScale {
    _imageMaximumZoomScale = imageMaximumZoomScale;
    self.scrollView.maximumZoomScale = _imageMaximumZoomScale;
}

/**
 计算contentSize应处于的中心位置
 */
- (CGPoint)centerOfContentSize {
    CGFloat deltaWidth = self.bounds.size.width - _scrollView.contentSize.width;
    CGFloat offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0;
    CGFloat deltaHeight = self.bounds.size.height - _scrollView.contentSize.height;
    CGFloat offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0;
    return CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)setImgUrl:(NSString *)imgUrl {
    _imgUrl = imgUrl;
    [_progressView setHidden:NO];
    [_imgView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:_imgUrl] placeholderImage:nil options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"图片开始加载");
        if (expectedSize > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
                _progressView.progress = progress;
            });
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"图片加载完成");
        [_progressView setHidden:YES];
        [self didlayout];
    }];
    [self didlayout];
}

/**
 取图片适屏size
 */
- (CGSize)fitSize {
    if (!_imgView.image) {
        return CGSizeZero;
    } else {
        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat scale = _imgView.image.size.height / _imgView.image.size.width;
        return CGSizeMake(width, scale * width);
    }
}

/**
 取图片适屏frame
 */
- (CGRect)fitFrame {
    CGSize size = self.fitSize;
    CGFloat y = (self.scrollView.bounds.size.height - size.height) > 0 ? (self.scrollView.bounds.size.height - size.height) * 0.5 : 0;
    return CGRectMake(0, y, size.width, size.height);
}

#pragma mark - 布局
- (void)didlayout {
    _scrollView.frame = self.contentView.bounds;
    [_scrollView setZoomScale:1.0 animated:NO];
    _imgView.frame = self.fitFrame;
    [_scrollView setZoomScale:1.0 animated:NO];
    _progressView.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _imgView.center = self.centerOfContentSize;
}

@end
