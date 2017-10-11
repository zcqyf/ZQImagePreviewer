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
#import "ScaleAnimator.h"
#import "ScaleAnimatorCoordinator.h"

@interface PhotoBrowser () <UICollectionViewDelegate, UICollectionViewDataSource, PBCollectionViewCellDelegate>

/**
 顶部页码显示label
 */
@property (nonatomic,strong) UILabel *pageLabel;

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
 是否已初始化视图，默认 NO
 */
@property (nonatomic,assign) BOOL didInitializedLayout;

/**
 自定义布局
 */
@property (nonatomic,strong) PhotoBroswerLayout *flowLayout;

@end

@implementation PhotoBrowser

#pragma mark - initialize
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"初始化");
        
        _photoSpacing = 20;
        _imageMaximumZoomScale = 2.0;
        _imageZoomScaleForDoubleTap = 2.0;
        _imageScaleMode = UIViewContentModeScaleAspectFill;
        _didInitializedLayout = NO;
        
        _flowLayout = [PhotoBroswerLayout new];
        _pageLabel = [UILabel new];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        
    }
    return self;
}

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupUI];
    [self initialLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _flowLayout.minimumLineSpacing = _photoSpacing;
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.itemSize = self.view.bounds.size;
    
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    _collectionView.backgroundColor = [UIColor blackColor];
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
    [_collectionView registerClass:[PBCollectionViewCell class] forCellWithReuseIdentifier: NSStringFromClass([PBCollectionViewCell class])];
    [self.view addSubview:_collectionView];
    
    _pageLabel.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 21);
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:_pageLabel];
    
    [self.collectionView reloadData];
}

#pragma mark - other setting
/**
 禁止旋转
 */
- (BOOL)shouldAutorotate {
    return NO;
}

//  隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)showWithIndex:(NSInteger)index {
    self.currentIndex = index;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
//    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionLeft) animated:NO];
    
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    [_presentingVC presentViewController:self animated:YES completion:nil];
}

#pragma mark - setter and getter
- (void)setImageUrls:(NSArray *)imageUrls {
    _imageUrls = imageUrls;
//    [_collectionView reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [_animatorCoordinator updateCurrentHiddenView:_relatedView];
//    _pageLabel.text = [NSString stringWithFormat:@"%ld / %lu", _currentIndex + 1, (unsigned long)_imageUrls.count];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCollectionViewCell *cell = (PBCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PBCollectionViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    cell.imgUrl = _imageUrls[indexPath.row];
    
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

#pragma mark - PBCollectionViewCellDelegate
//  点击退出 browser
- (void)photoBrowserCellDidSingleTap:(PBCollectionViewCell *)cell {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    PBCollectionViewCell *cell = (PBCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imgView.image];
    imageView.contentMode = _imageScaleMode;
    imageView.clipsToBounds = YES;
    
    //在本方法被调用时，endView和scaleView还未确定。需于viewDidLoad方法中给animator赋值endView
    ScaleAnimator *animator = [[ScaleAnimator alloc] initWithStartView:self.relatedView endView:cell.imgView scaleView:imageView];
    _presentationAnimator = animator;
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    PBCollectionViewCell *cell = (PBCollectionViewCell *)self.collectionView.visibleCells.firstObject;
    if (!cell) {
        return nil;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imgView.image];
    imageView.contentMode = _imageScaleMode;
    imageView.clipsToBounds = YES;
    return [[ScaleAnimator alloc] initWithStartView:cell.imgView endView:self.relatedView scaleView:imageView];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    ScaleAnimatorCoordinator *coordinator = [[ScaleAnimatorCoordinator alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    coordinator.currentHiddenView = _relatedView;
    _animatorCoordinator = coordinator;
    
    return coordinator;
}

//  长按保存图片
- (void)photoBroswerCell:(PBCollectionViewCell *)cell didLongPressWith:(UIImage *)image {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"保存图片");
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [actionSheet addAction:saveAction];
    [actionSheet addAction:cancelAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
