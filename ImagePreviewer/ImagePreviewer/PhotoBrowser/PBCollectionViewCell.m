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

@interface PBCollectionViewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
/// 放大缩小容器
@property (nonatomic,strong) UIScrollView *scrollView;

/// 自定义进度显示view
@property (nonatomic,strong) PhotoBrowserProgressView *progressView;

/// 计算contentSize应处于的中心位置
@property (nonatomic,assign) CGPoint centerOfContentSize;

/// 取图片适屏size
@property (nonatomic,assign) CGSize fitSize;

/// 取图片适屏frame
@property (nonatomic,assign) CGRect fitFrame;

/// 记录pan手势开始时imageView的位置
@property (nonatomic,assign) CGRect beganFrame;

/// 记录pan手势开始时，手势位置
@property (nonatomic,assign) CGPoint beganTouch;

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
        
        //  长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.contentView addGestureRecognizer:longPress];
        //  双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTap];
        //  单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self.contentView addGestureRecognizer:singleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        //  平移手势
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//        pan.delegate = self;
//        [_scrollView addGestureRecognizer:pan];
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

//  响应平移
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (!_imgView.image) {
        return;
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.beganFrame = _imgView.frame;
            self.beganTouch = [pan locationInView:_scrollView];
            break;
        case UIGestureRecognizerStateChanged:
        {
            //拖动偏移量
            CGPoint translation = [pan translationInView:_scrollView];
            CGPoint currentTouch = [pan locationInView:_scrollView];
            //由下拉的偏移值决定缩放比例，越往下便宜，缩得越小。scale值区间 [0.3 1.0]
            CGFloat scale = MIN(1.0, MAX(0.3, 1 - translation.y / self.bounds.size.height));
            
            CGFloat width = _beganFrame.size.width * scale;
            CGFloat height = _beganFrame.size.height * scale;
            
            //计算x和y。保持手指在图片上的相应位置不变。
            //即如果手势开始时，手指在图片x轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
            CGFloat xRate = (_beganTouch.x - _beganFrame.origin.x) / _beganFrame.size.width;
            CGFloat currentTouchDeltax = xRate * width;
            CGFloat x = currentTouch.x - currentTouchDeltax;
            
            CGFloat yRate = (_beganTouch.y - _beganFrame.origin.y) /_beganFrame.size.height;
            CGFloat currentTouchDeltaY = yRate * height;
            CGFloat y = currentTouch.y - currentTouchDeltaY;
            
            _imgView.frame = CGRectMake(x, y, width, height);
            
            //  通知代理，发生了缩放。代理可依scale值改变背景蒙板alpha值
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoBroswerCell:didPanScale:)]) {
                [self.delegate photoBroswerCell:self didPanScale:scale];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if ([pan velocityInView:self].y > 0) {
                //  dismiss
                [self singleTapAction];
            } else {
                //  取消 dismiss
                [self endPan];
            }
            break;
        default:
            [self endPan];
            break;
    }
}

- (void)endPan {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBroswerCell:didPanScale:)]) {
        [self.delegate photoBroswerCell:self didPanScale:1.0];
    }
    // 如果图片当前显示的size小于原size，则重置为原size
    CGSize size = self.fitSize;
    BOOL needResetSize = (_imgView.bounds.size.width < size.width || _imgView.bounds.size.height < size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.imgView.center = self.centerOfContentSize;
        if (needResetSize) {
            //            self.imageView.bounds.size = size;
            self.imgView.frame = CGRectMake(_imgView.frame.origin.x, _imgView.frame.origin.y, size.width, size.height);
        }
    }];
}


#pragma mark - getter and setter
- (void)setImageMaximumZoomScale:(CGFloat)imageMaximumZoomScale {
    _imageMaximumZoomScale = imageMaximumZoomScale;
    self.scrollView.maximumZoomScale = _imageMaximumZoomScale;
}

/// 计算contentSize应处于的中心位置
- (CGPoint)centerOfContentSize {
    CGFloat deltaWidth = self.bounds.size.width - _scrollView.contentSize.width;
    CGFloat offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0;
    CGFloat deltaHeight = self.bounds.size.height - _scrollView.contentSize.height;
    CGFloat offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0;
    return CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)setImgUrl:(NSURL *)imgUrl {
    _imgUrl = imgUrl;
    [_progressView setHidden:NO];
    [_imgView sd_setImageWithPreviousCachedImageWithURL: imgUrl placeholderImage:nil options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
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

/// 取图片适屏size
- (CGSize)fitSize {
    if (!_imgView.image) {
        return CGSizeZero;
    } else {
        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat scale = _imgView.image.size.height / _imgView.image.size.width;
        return CGSizeMake(width, scale * width);
    }
}

/// 取图片适屏frame
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //  只响应pan手势
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint velocity = [pan velocityInView:self];
    //  向上滑动时，不响应手势
    if (velocity.y < 0) {
        return NO;
    }
    //  横向滚动时，不响应pan手势
    if (abs((int)velocity.x > (int)velocity.y)) {
        return NO;
    }
    //  向下滑动，如果图片顶部超出可视区域，不响应手势
    if (_scrollView.contentOffset.y > 0) {
        return NO;
    }
    return YES;
}


@end
