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

@interface PhotoBroswer () <UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate, PhotoBrowserCellDelegate>

/**
 本VC的presentingViewController
 */
@property (nonatomic,strong) UIViewController *presentingVC;

/**
 当前浏览图片的 index
 */
@property (nonatomic,assign) NSInteger currentIndex;

/**
 横向容器
 */
@property (nonatomic,strong) UICollectionView *collectionView;

/**
 自定义布局
 */
@property (nonatomic,strong) PhotoBroswerLayout *flowLayout;

/**
 当前正在显示视图的前一个页面关联视图
 */
@property (nonatomic,strong) UIView *relatedView;

/**
 转场协调器
 */
@property (nonatomic,weak) ScaleAnimatorCoordinator *animatorCoordinator;

/**
 presentation 转场动画
 */
@property (nonatomic,weak) ScaleAnimator *presentationAnimator;

/**
 PageControl TODO lazy
 */
//@property (nonatomic,strong) UIView *pageControl;

/**
 标记第一次 viewDidAppeared，默认 NO
 */
@property (nonatomic,assign) BOOL onceViewDidAppeared;

/**
 保存原 windowLevel
 */
@property (nonatomic,assign) UIWindowLevel originWindowLevel;

/**
 是否已初始化视图，默认 NO
 */
@property (nonatomic,assign) BOOL didInitializedLayout;

@end

@implementation PhotoBroswer

#pragma mark - 初始化
- (instancetype)initWithPresentingVC:(UIViewController *)viewController delegate:(id<PhotoBroswerDelegate>)delegate {
    self.presentingVC = viewController;
    self.photoBroswerDelegate = delegate;
    
    self.photoSpacing = 30;
    self.imageScaleMode = UIViewContentModeScaleAspectFill;
    self.imageMaximumZoomScale = 2.0;
    self.imageZoomScaleForDoubleTap = 2.0;
    self.onceViewDidAppeared = NO;
    self.didInitializedLayout = NO;
    
    self.flowLayout = [[PhotoBroswerLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    
    return self;
}

- (void)showWithPresentingVC:(UIViewController *)viewControlelr delegate:(id<PhotoBroswerDelegate>)delegate index:(NSInteger)index {
    PhotoBroswer *broswer = [[PhotoBroswer alloc] initWithPresentingVC:viewControlelr delegate:delegate];
    [broswer show:index];
}

- (void)show:(NSInteger)index {
    _currentIndex = index;
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    [_presentingVC presentViewController:self animated:YES completion:nil];
}

#pragma mark - setter and getter
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self.animatorCoordinator updateCurrentHiddenView:_relatedView];
    if (self.pageControlDelegate && self.pageControl) {
        [self.pageControlDelegate photoBrowserPageControl:self.pageControl didChangedCurrentPage:_currentIndex];
    }
}

- (UIView *)relatedView {
    return [self.photoBroswerDelegate photoBrowser:self thumbnailViewForIndex:_currentIndex];
}

- (UIView *)pageControl {
    return [self.pageControlDelegate pageControlOfPhotoBrowser:self];
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialLayout];
}

/**
 加载视图并布局
 */
- (void)initialLayout {
    if (self.didInitializedLayout) {
        return;
    }
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

//  遮盖状态栏。以改变windowLevel的方式遮盖
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
//  显示pageControl
- (void)layoutPageControl {
    if (!self.pageControlDelegate) {
        return;
    }
    //  如果只有一页，不显示
    if (self.pageControlDelegate.numberOfPages <= 1) {
        return;
    }
    if (!_onceViewDidAppeared && (self.pageControl)) {
        _onceViewDidAppeared = YES;
        [self.view addSubview:self.pageControl];
        [self.pageControlDelegate photoBrowserPageControl:self.pageControl didMoveTo:self.view];
    }
    [self.pageControlDelegate photoBrowserPageControl:self.pageControl needLayoutIn:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionView dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

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
    [cell setImageWithDictionary:[self imageForIndex:indexPath.item]];
    cell.imageMaximumZoomScale = _imageMaximumZoomScale;
    cell.imageZoomScaleForDoubleTap = _imageZoomScaleForDoubleTap;
    
    return cell;
}

- (NSDictionary *)imageForIndex:(NSInteger)index {
    
    if (!self.photoBroswerDelegate) {
        return nil;
    }
    //缩略图
    UIImage *thumImage = [self.photoBroswerDelegate photoBrowser:self thumbnailImageForIndex:index];
    //高清图url
    NSString *highQualityUrl = [self.photoBroswerDelegate photoBrowser:self highQualityUrlStringForIndex:index];
    //原图url
//    NSString *rawUrl = [self.photoBroswerDelegate photoBrowser:self rawUrlStringForIndex:index];
    
    return @{
             @"thumImage": thumImage,
             @"highQualityUrl": highQualityUrl,
             };
}

#pragma mark - collectionView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width + _photoSpacing;
    _currentIndex = (NSInteger)(offsetX / width);
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    //  视图布局
    [self initialLayout];
    //立即加载collectionView
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [_collectionView layoutIfNeeded];
    
    PhotoBrowserCell *cell = (PhotoBrowserCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imageView.contentMode = _imageScaleMode;
    imageView.clipsToBounds = YES;
    
    //在本方法被调用时，endView和scaleView还未确定。需于viewDidLoad方法中给animator赋值endView
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
    coordinator.currentHiddenView = _relatedView;
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
