//
//  PhotoBroswer.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "PhotoBroswer.h"
#import "PhotoBroswerLayout.h"
#import "PhotoBrowserCell.h"
#import "ScaleAnimator.h"
#import "ScaleAnimatorCoordinator.h"

@interface PhotoBroswer () <UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PhotoBrowserCellDelegate>

// MARK: -  内部属性
/// 当前显示的图片序号，从0开始
@property (nonatomic,assign) NSInteger currentIndex;

/// 当前正在显示视图的前一个页面关联视图
@property (nonatomic,strong) UIView *relatedView;

/// 转场协调器
@property (nonatomic,weak) ScaleAnimatorCoordinator *animatorCoordinator;

/// presentation转场动画
@property (nonatomic,weak) ScaleAnimator *presentationAnimator;

/// 本VC的presentingViewController
@property (nonatomic,strong) UIViewController *presentingVC;

/// 容器
@property (nonatomic,strong) UICollectionView *collectionView;

/// 容器layout
@property (nonatomic,strong) PhotoBroswerLayout *flowLayout;

/// PageControl
@property (nonatomic,strong) UIView *pageControl;

/// 标记第一次viewDidAppeared
@property (nonatomic,assign) BOOL onceViewDidAppeared;

/// 保存原windowLevel
@property (nonatomic,assign) UIWindowLevel originWindowLevel;

/// 是否已初始化视图
@property (nonatomic,assign) BOOL didInitializedLayout;

@end

@implementation PhotoBroswer

#pragma mark - 初始化
- (instancetype)initWithPresentingVC:(UIViewController *)viewController delegate:(id<PhotoBroswerDelegate>)delegate {
    
    _presentingVC = viewController;
    _photoBroswerDelegate = delegate;
    
    _currentIndex = 0;
    _photoSpacing = 30;
    _imageMaximumZoomScale = 2.0;
    _imageZoomScaleForDoubleTap = 2.0;
    _imageScaleMode = UIViewContentModeScaleAspectFill;
    _onceViewDidAppeared = NO;
    _didInitializedLayout = NO;
    
    _flowLayout = [[PhotoBroswerLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    
    return self;
}

- (void)showWithPresentingVC:(UIViewController *)viewControlelr delegate:(id<PhotoBroswerDelegate>)delegate index:(NSInteger)index {
    PhotoBroswer *broswer = [[PhotoBroswer alloc] initWithPresentingVC:viewControlelr delegate:delegate];
    [broswer show:index];
}

- (void)show:(NSInteger)index {
    self.currentIndex = index;
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    [_presentingVC presentViewController:self animated:YES completion:nil];
}

#pragma mark - setter and getter
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self.animatorCoordinator updateCurrentHiddenView:self.relatedView];
    
    if (self.pageControlDelegate && self.pageControl) {
        [self.pageControlDelegate photoBrowserPageControl:self.pageControl didChangedCurrentPage:self.currentIndex];
    }
}

- (UIView *)relatedView {
    return [self.photoBroswerDelegate photoBrowser:self thumbnailViewForIndex:self.currentIndex];
}

//- (UIView *)pageControl {
//    return [self.pageControlDelegate pageControlOfPhotoBrowser:self];
//}

- (UIView *)pageControl {
    if (!_pageControl) {
        _pageControl = [self.pageControlDelegate pageControlOfPhotoBrowser:self];
    }
    return _pageControl;
}

#pragma mark - lifecycle
// MARK: - 内部方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialLayout];
}

/// 初始layout
- (void)initialLayout {
    if (self.didInitializedLayout) {
        return;
    }
    
    self.view.backgroundColor = [UIColor greenColor];
    
    _didInitializedLayout = YES;
    
    // flowLayout
    _flowLayout.minimumLineSpacing = _photoSpacing;
    _flowLayout.itemSize = self.view.bounds.size;
    
    //collectionView
    _collectionView.frame = self.view.bounds;
    _collectionView.backgroundColor = [UIColor clearColor];
    //设置减速速率
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[PhotoBrowserCell class] forCellWithReuseIdentifier: NSStringFromClass([PhotoBrowserCell class])];
    [self.view addSubview:_collectionView];
}

/// 显示pageControl
- (void)layoutPageControl {
    if (!self.pageControlDelegate) {
        return;
    }
    //  如果只有一页，不显示
    if (self.pageControlDelegate.numberOfPages <= 1) {
        return;
    }
    if (!_onceViewDidAppeared && self.pageControl) {
        _onceViewDidAppeared = YES;
        [self.view addSubview:self.pageControl];
        [self.pageControlDelegate photoBrowserPageControl:self.pageControl didMoveTo:self.view];
    }
    [self.pageControlDelegate photoBrowserPageControl:self.pageControl needLayoutIn:self.view];
}

/// 遮盖状态栏。以改变windowLevel的方式遮盖
- (void)hideStatusBar:(BOOL)isHide {
    
    UIWindow *win;
    if (!self.view.window) {
        win = UIApplication.sharedApplication.keyWindow;
    } else {
        win = self.view.window;
    }
    UIWindow *window = win;
    if (!window) {
        return;
    }
    
    if (!_originWindowLevel) {
        _originWindowLevel = window.windowLevel;
    }
    
    if (isHide) {
        if (window.windowLevel == UIWindowLevelStatusBar + 1) {
            return;
        }
        window.windowLevel = UIWindowLevelStatusBar + 1;
    } else {
        if (window.windowLevel == _originWindowLevel) {
            return;
        }
        window.windowLevel = _originWindowLevel;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //  遮盖状态栏
    [self hideStatusBar:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //  页面出来后，再显示pageControl
//    [self layoutPageControl];
}

/**
 禁止旋转
 */
- (BOOL)shouldAutorotate {
    return NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionView dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.photoBroswerDelegate) {
        return 0;
    }
    return [self.photoBroswerDelegate numberOfPhotosInPhotoBroswer:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoBrowserCell class]) forIndexPath:indexPath];
    cell.imageView.contentMode = _imageScaleMode;
    cell.photoBroswerCellDelegate = self;
    cell.backgroundColor = [UIColor redColor];
    [cell setImageWithDictionary:[self getImageInfoAt:indexPath.item]];
    cell.imageMaximumZoomScale = _imageMaximumZoomScale;
    cell.imageZoomScaleForDoubleTap = _imageZoomScaleForDoubleTap;
    
    return cell;
}

- (NSDictionary *)getImageInfoAt:(NSInteger)index {
    
    if (!self.photoBroswerDelegate) {
        NSLog(@"photoBroswerDelegate为空");
        return @{};
    }
    //  缩略图
    UIImage *thumnailImage = [self.photoBroswerDelegate photoBrowser:self thumbnailImageForIndex:index];
    //  高清图 url
    NSURL *highQualityUrl = [self.photoBroswerDelegate photoBrowser:self highQualityUrlForIndex:index];
    //  原图url
//    NSURL *rawUrl = [self.photoBroswerDelegate photoBrowser:self rawUrlForIndex:index];
    NSDictionary *dict = @{@"thumnailImage": thumnailImage, @"highQualityUrl": highQualityUrl, @"rawUrl": @""};
    
    return dict;
}

#pragma mark - collectionView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width + _photoSpacing;
    self.currentIndex = (NSInteger)(offsetX / width);
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    //  视图布局
    [self initialLayout];
    //立即加载collectionView
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [_collectionView layoutIfNeeded];
    
    PhotoBrowserCell *cell = (PhotoBrowserCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imageView.contentMode = _imageScaleMode;
    imageView.clipsToBounds = YES;
    
    // 创建animator
    ScaleAnimator *animator = [[ScaleAnimator alloc] initWithStartView:self.relatedView endView:cell.imageView scaleView:imageView];
    _presentationAnimator = animator;
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    PhotoBrowserCell *cell = (PhotoBrowserCell *)self.collectionView.visibleCells.firstObject;
    if (!cell) {
        return nil;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imageView.contentMode = _imageScaleMode;
    imageView.clipsToBounds = YES;
    return [[ScaleAnimator alloc] initWithStartView:cell.imageView endView:self.relatedView scaleView:imageView];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    ScaleAnimatorCoordinator *coordinator = [[ScaleAnimatorCoordinator alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    coordinator.currentHiddenView = self.relatedView;
    _animatorCoordinator = coordinator;
    
    return coordinator;
}

#pragma mark - PhotoBrowserCellDelegate
- (void)photoBroswerCellDidSingleTap:(PhotoBrowserCell *)cell {
    [self hideStatusBar:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoBroswerCell:(PhotoBrowserCell *)cell didPanScale:(CGFloat)scale {
    // 实测用scale的平方，效果比线性好些
    CGFloat alpha = scale * scale;
    _animatorCoordinator.maskView.alpha = alpha;
    // 半透明时重现状态栏，否则遮盖状态栏
    [self hideStatusBar:(alpha >= 1.0)];
}

- (void)photoBroswerCell:(PhotoBrowserCell *)cell didLongPressWith:(UIImage *)image {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    if (indexPath) {
        [self.photoBroswerDelegate photoBrowser:self didLongPressForIndex:indexPath.item image:image];
    }
}

@end
