//
//  PhotoBrowserCell.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "PhotoBrowserCell.h"

@interface PhotoBrowserCell () <UIScrollViewDelegate>

/**
 内嵌容器
 */
@property (nonatomic,strong) UIScrollView *scrollView;

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
@property (nonatomic,assign) CGPoint beganPoint;

@end

@implementation PhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupGesture];
    }
    return self;
}

- (void)setupUI {
    _imageView = [UIImageView new];
    _imageView.clipsToBounds = YES;
    [self.scrollView addSubview:_imageView];
    [self.contentView addSubview:self.scrollView];
}

- (void)setupGesture {
    _imageView.userInteractionEnabled = YES;
    //双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:doubleTap];
    //单击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [_imageView addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    //拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [_imageView addGestureRecognizer:pan];
    
}

- (void)doubleTap:(UITapGestureRecognizer *)sender {
    CGFloat scale = self.scrollView.maximumZoomScale;
    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
        scale = 1.0;
    }
    [self.scrollView setZoomScale:scale animated:YES];
}

- (void)singleTap:(UITapGestureRecognizer *)sender {
    if (self.photoBroswerCellDelegate && [self.photoBroswerCellDelegate respondsToSelector:@selector(photoBroswerCellDidSingleTap:)]) {
        [self.photoBroswerCellDelegate photoBroswerCellDidSingleTap:self];
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.beganFrame = _imageView.frame;
            self.beganPoint = [pan locationInView:pan.view.superview];
            break;
        case UIGestureRecognizerStateChanged:
            {
                //拖动偏移量
                CGPoint translation = [pan translationInView:self];
                CGPoint currentTouch = [pan locationInView:pan.view.superview];
                //由下拉的偏移值决定缩放比例，越往下便宜，缩得越小。scale值区间 [0.3 1.0]
                CGFloat scale = MIN(1.0, MAX(0.3, 1 - translation.y / self.bounds.size.height));
                
                CGSize theFitSize = self.fitSize;
                CGFloat width = theFitSize.width * scale;
                CGFloat height = theFitSize.height * scale;
                
                //计算x和y。保持手指在图片上的相应位置不变。
                //即如果手势开始时，手指在图片x轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
                CGFloat xRate = (_beganPoint.x - _beganFrame.origin.x) / _beganFrame.size.width;
                CGFloat currentTouchDeltax = xRate * height;
                
                
            }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            break;
        default:
            break;
    }
}

#pragma mark - lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

#pragma mark - setter
- (CGSize)fitSize {
    if (!_imageView.image) {
        return CGSizeZero;
    } else {
        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat scale = _imageView.image.size.height / _imageView.image.size.width;
        return CGSizeMake(width, scale * width);
    }
}

- (CGRect)fitFrame {
    CGSize size = self.fitSize;
    CGFloat y = self.scrollView.bounds.size.height - size.height;
    return CGRectMake(0, y, size.width, size.height);
}

#pragma mark - 布局
- (void)didlayout {
    self.scrollView.frame = self.contentView.bounds;
    [self.scrollView setZoomScale:1.0 animated:NO];
    _imageView.frame = self.fitFrame;
    //TODO progressView
    
}



- (void)setImageWithPlaceHolder:(UIImage *)image url:(NSString *)url {
    if (!url) {
        _imageView.image = image;
        [self didlayout];
        return;
    }
    //TODO progressView
    
    //TODO network get image
    
    [self didlayout];
}

#pragma mark - scrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //TODO difference
    _imageView.center = self.center;
    
}


@end























