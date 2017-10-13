//
//  PhotoBrowser.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/10.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "PhotoBrowser.h"
#import "PhotoBroswerLayout.h"
#import "PBCollectionViewCell.h"

#import "ImageScaleAnimator.h"
#import "ImageScaleAnimatorCoordinator.h"

@interface PhotoBrowser () <UICollectionViewDelegate, UICollectionViewDataSource, PBCollectionViewCellDelegate, UIViewControllerTransitioningDelegate>

/// 本VC的presentingViewController
@property (nonatomic,strong) UIViewController *presentingVC;

/// 当前浏览图片的 index
@property (nonatomic,assign) NSInteger currentIndex;

/// 横向容器
@property (nonatomic,strong) UICollectionView *collectionView;

/// 顶部页码显示label
@property (nonatomic,strong) UILabel *pageLabel;

/// 自定义布局
@property (nonatomic,strong) PhotoBroswerLayout *flowLayout;

/// 当前正在显示视图的前一个页面关联视图
@property (nonatomic,strong) UIView *relatedView;

@property (nonatomic,assign) BOOL isFirstTimeLayout;

/// 转场协调器
@property (nonatomic,weak) ImageScaleAnimatorCoordinator *animatorCoordinator;

@end

@implementation PhotoBrowser

#pragma mark - initialize
- (instancetype)init
{
    self = [super init];
    if (self) {
        _photoSpacing = 20;
        _imageMaximumZoomScale = 2.0;
        _imageZoomScaleForDoubleTap = 2.0;
        _imageScaleMode = UIViewContentModeScaleAspectFill;
        _isFirstTimeLayout = YES;
        
        _flowLayout = [PhotoBroswerLayout new];
        _pageLabel = [UILabel new];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    }
    return self;
}

- (instancetype)initWithPresentingVC:(UIViewController *)viewController delegate:(id<PhotoBrowserDelegate>)delegate {
    
    _presentingVC = viewController;
    _delegate = delegate;
    
    _photoSpacing = 20;
    _imageMaximumZoomScale = 2.0;
    _imageZoomScaleForDoubleTap = 2.0;
    _imageScaleMode = UIViewContentModeScaleAspectFill;
    _isFirstTimeLayout = YES;
    
    _flowLayout = [PhotoBroswerLayout new];
    _pageLabel = [UILabel new];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    
    return self;
}

- (void)showWithPresentingVC:(UIViewController *)viewControlelr delegate:(id<PhotoBrowserDelegate>)delegate index:(NSInteger)index {
    PhotoBrowser *broswer = [[PhotoBrowser alloc] initWithPresentingVC:viewControlelr delegate:delegate];
    
    [broswer showWithIndex:index];
}

- (void)showWithIndex:(NSInteger)index {
    
    self.currentIndex = index;
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    [_presentingVC presentViewController:self animated:YES completion:nil];
}

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self layout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)layout {
    
    if (!_isFirstTimeLayout) {
        return;
    }
    _isFirstTimeLayout = NO;
    
    _flowLayout.minimumLineSpacing = _photoSpacing;
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.itemSize = self.view.bounds.size;
    
    _collectionView.frame = self.view.bounds;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    [_collectionView registerClass:[PBCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([PBCollectionViewCell class])];
    [self.view addSubview:_collectionView];
    
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 21)];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:_pageLabel];
    
    [self setUpPageLabel];
}

#pragma mark - other setting
/// 设置顶部页码
- (void)setUpPageLabel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfPhotosInPhotoBroswer:)]) {
        _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", _currentIndex + 1, [self.delegate numberOfPhotosInPhotoBroswer:self]];
    }
}

/// 禁止旋转
- (BOOL)shouldAutorotate {
    return NO;
}

//  隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - setter and getter
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self setUpPageLabel];
    
    [_animatorCoordinator updateCurrentHiddenView:self.relatedView];
}

- (UIView *)relatedView {
    return [self.delegate photoBrowser:self thumbnailViewForIndex:self.currentIndex];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfPhotosInPhotoBroswer:)]) {
        return [self.delegate numberOfPhotosInPhotoBroswer:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCollectionViewCell *cell = (PBCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PBCollectionViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:highQualityUrlForIndex:)]) {
        NSURL *url = [self.delegate photoBrowser:self highQualityUrlForIndex:indexPath.item];
        cell.imgUrl = url;
    }
    cell.imageMaximumZoomScale = _imageMaximumZoomScale;
    cell.imageZoomScaleForDoubleTap = _imageZoomScaleForDoubleTap;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
//  scrollView滚动就会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width + _photoSpacing;
    
    CGFloat temp = offsetX / width;
    
    if (temp <= _currentIndex - 0.8) {
        self.currentIndex = (NSInteger)temp;
    }
    if (temp >= _currentIndex + 0.8) {
        self.currentIndex += 1;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    //  视图布局
    [self layout];
    //  立即加载collectionView
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [_collectionView layoutIfNeeded];
    
    PBCollectionViewCell *cell = (PBCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imgView.image];
    imageView.contentMode = _imageScaleMode;
    imageView.clipsToBounds = YES;
    
    //  创建animator
    ImageScaleAnimator *animator = [[ImageScaleAnimator alloc] initWithStartView:self.relatedView scaleView:imageView endView:cell.imgView isPresented:YES];
    
    return animator;
}


-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    PBCollectionViewCell *cell = (PBCollectionViewCell *)_collectionView.visibleCells.firstObject;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imgView.image];
    imageView.contentMode = _imageScaleMode;
    imageView.clipsToBounds = YES;
    
    return [[ImageScaleAnimator alloc] initWithStartView:cell.imgView scaleView:imageView endView:self.relatedView isPresented:NO];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    ImageScaleAnimatorCoordinator *coordinator = [[ImageScaleAnimatorCoordinator alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    coordinator.currentHiddenView = self.relatedView;
    _animatorCoordinator = coordinator;

    return coordinator;
}

//
//-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
//    return self.transitionController.interacting ? self.transitionController : nil;
//}


#pragma mark - PBCollectionViewCellDelegate
//  点击退出 browser
- (void)photoBrowserCellDidSingleTap:(PBCollectionViewCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:dismissAtIndex:)]) {
        [self.delegate photoBrowser:self dismissAtIndex:_currentIndex];
    }
}

//  长按保存图片
- (void)photoBroswerCell:(PBCollectionViewCell *)cell didLongPressWith:(UIImage *)image {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        //  TODO保存图片到相册
        NSLog(@"保存图片");
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [actionSheet addAction:saveAction];
    [actionSheet addAction:cancelAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)photoBroswerCell:(PBCollectionViewCell *)cell didPanScale:(CGFloat)scale {
    // 实测用scale的平方，效果比线性好些
    CGFloat alpha = scale * scale;
    _animatorCoordinator.maskView.alpha = alpha;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
