//
//  PhotoBrowserCell.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "PhotoBrowserCell.h"
#import "PhotoBrowserProgressView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PhotoBrowserCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

/**
 内嵌容器
 */
@property (nonatomic,strong) UIScrollView *scrollView;

/**
 加载进度指示器
 */
@property (nonatomic,strong) PhotoBrowserProgressView *progressView;

/**
 查看原图按钮
 */
@property (nonatomic,strong) UIButton *rawImageButton;

/**
 取图片适屏size
 */
@property (nonatomic,assign) CGSize fitSize;

/**
 取图片适屏frame
 */
@property (nonatomic,assign) CGRect fitFrame;


/**
 记录pan手势开始时imageView的位置
 */
@property (nonatomic,assign) CGRect beganFrame;

/**
 记录pan手势开始时，手势位置
 */
@property (nonatomic,assign) CGPoint beganTouch;

/**
 计算contentSize应处于的中心位置
 */
@property (nonatomic,assign) CGPoint centerOfContentSize;

@end

@implementation PhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageMaximumZoomScale = 2.0;
        self.imageZoomScaleForDoubleTap = 2.0;
        self.beganFrame = CGRectZero;
        self.beganTouch = CGPointZero;
        
        [self setupUI];
        [self setupGesture];
    }
    return self;
}

- (void)setupUI {
    //  scrollView
    _scrollView = [UIScrollView new];
    [self.contentView addSubview:_scrollView];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = _imageMaximumZoomScale;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    //  imageView
    _imageView = [UIImageView new];
    _imageView.clipsToBounds = YES;
    [_scrollView addSubview:_imageView];
    
    //  progressView
    _progressView = [PhotoBrowserProgressView new];
    [self.contentView addSubview:_progressView];
    [_progressView setHidden:YES];
}

- (void)setupGesture {
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
    
    //拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [_scrollView addGestureRecognizer:pan];
}

//  响应长按
- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan && (self.photoBroswerCellDelegate && [self.photoBroswerCellDelegate respondsToSelector:@selector(photoBroswerCell:didLongPressWith:)]) && self.imageView.image) {
        [self.photoBroswerCellDelegate photoBroswerCell:self didLongPressWith:self.imageView.image];
    }
}

//  响应双击
- (void)doubleTap:(UITapGestureRecognizer *)sender {
    // 如果当前没有任何缩放，则放大到目标比例
    // 否则重置到原比例
    if (_scrollView.zoomScale == 1.0) {
        // 以点击的位置为中心，放大
        CGPoint pointInView = [sender locationInView:_imageView];
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
    if (self.photoBroswerCellDelegate && [self.photoBroswerCellDelegate respondsToSelector:@selector(photoBroswerCellDidSingleTap:)]) {
        [self.photoBroswerCellDelegate photoBroswerCellDidSingleTap:self];
    }
}

//  响应平移
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (!_imageView.image) {
        return;
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.beganFrame = _imageView.frame;
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
                
                _imageView.frame = CGRectMake(x, y, width, height);
                
                //  通知代理，发生了缩放。代理可依scale值改变背景蒙板alpha值
                if (self.photoBroswerCellDelegate && [self.photoBroswerCellDelegate respondsToSelector:@selector(photoBroswerCell:didPanScale:)]) {
                    [self.photoBroswerCellDelegate photoBroswerCell:self didPanScale:scale];
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
    
    if (self.photoBroswerCellDelegate && [self.photoBroswerCellDelegate respondsToSelector:@selector(photoBroswerCell:didPanScale:)]) {
        [self.photoBroswerCellDelegate photoBroswerCell:self didPanScale:1.0];
    }
    // 如果图片当前显示的size小于原size，则重置为原size
    CGSize size = self.fitSize;
    BOOL needResetSize = (_imageView.bounds.size.width < size.width || _imageView.bounds.size.height < size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.center = self.centerOfContentSize;
        if (needResetSize) {
//            self.imageView.bounds.size = size;
            self.imageView.frame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, size.width, size.height);
        }
    }];
}

#pragma mark - lazy
- (UIButton *)rawImageButton {
    if (!_rawImageButton) {
        _rawImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rawImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rawImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_rawImageButton setTitle:@"查看原图" forState:UIControlStateNormal];
        [_rawImageButton setTitle:@"查看原图" forState:UIControlStateHighlighted];
        _rawImageButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _rawImageButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _rawImageButton.layer.borderWidth = 1;
        _rawImageButton.layer.cornerRadius = 4;
        _rawImageButton.layer.masksToBounds = YES;
        [_rawImageButton addTarget:self action:@selector(onRawImageButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rawImageButton;
}

- (void)onRawImageButtonTap:(UIButton *)sender {
    [self loadImageWithPlaceHolder:_imageView.image url:_rawUrl];
    [_rawImageButton setHidden:YES];
}

#pragma mark - setter and getter
- (void)setImageMaximumZoomScale:(CGFloat)imageMaximumZoomScale {
    _imageMaximumZoomScale = imageMaximumZoomScale;
    self.scrollView.maximumZoomScale = _imageMaximumZoomScale;
}

/**
 取图片适屏size
 */
- (CGSize)fitSize {
    if (!_imageView.image) {
        return CGSizeZero;
    } else {
        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat scale = _imageView.image.size.height / _imageView.image.size.width;
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

#pragma mark - 布局
- (void)didlayout {
    _scrollView.frame = self.contentView.bounds;
    [_scrollView setZoomScale:1.0 animated:NO];
    _imageView.frame = self.fitFrame;
    [_scrollView setZoomScale:1.0 animated:NO];
    _progressView.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
    //查看原图按钮
    if (!_rawImageButton.isHidden) {
        [self.contentView addSubview:_rawImageButton];
        [_rawImageButton sizeToFit];
        CGFloat width = _rawImageButton.bounds.size.width + 14;
        _rawImageButton.frame = CGRectMake(_rawImageButton.frame.origin.x, _rawImageButton.frame.origin.y, width, _rawImageButton.frame.size.height);
        _rawImageButton.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), self.contentView.bounds.size.height - 20 - _rawImageButton.bounds.size.height);
        [_rawImageButton setHidden:NO];
    }
}

/**
 设置图片
 */
- (void)setImageWithDictionary:(NSDictionary *)dict {
    //  查看原图按钮
    NSString *rawUrl = dict[@"rawUrl"];
    UIImage *image = dict[@"thumImage"];
    NSString *highQualityUrl = dict[@"highQualityUrl"];
    
    [_rawImageButton setHidden:(rawUrl == nil)];
    self.rawUrl = rawUrl;
    
    //  取placeholder图像，默认使用传入的缩略图
    UIImage *placeholder;
    NSString *url;
    
    // 若已有原图缓存，优先使用原图
    // 次之使用高清图
    UIImage *cacheImage;
    if ([self imageFor:rawUrl])
    {
        cacheImage = [self imageFor:rawUrl];
        placeholder = cacheImage;
        url = rawUrl;
        [_rawImageButton setHidden:YES];
    }
    else if ([self imageFor:highQualityUrl])
    {
        cacheImage = [self imageFor:highQualityUrl];
        placeholder = cacheImage;
    }
    // 处理只配置了原图而不配置高清图的情况。此时使用原图代替高清图作为下载url
    if (!highQualityUrl) {
        url = rawUrl;
    }
    if (!url) {
        _imageView.image = image;
        [self didlayout];
        return;
    }
    [self loadImageWithPlaceHolder:placeholder url:url];
}

//加载图片
- (void)loadImageWithPlaceHolder:(UIImage *)placeholder url:(NSString *)url {
    [self.progressView setHidden:NO];
    __weak typeof(self) weakSelf = self;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (expectedSize > 0) {
            weakSelf.progressView.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakSelf.progressView setHidden:YES];
        [weakSelf didlayout];
    }];
}

- (UIImage *)imageFor:(NSString *)url {

    UIImage *cacheImage;
//    SDWebImageManager
    SDImageCache


    return [UIImage new];
}

#pragma mark - scrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _imageView.center = self.centerOfContentSize;;
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
