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
 用于模态推送
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
@property (nonatomic,strong) UIView *relateView;

@property (nonatomic,weak) ScaleAnimatorCoordinator *animatorCoordinator;

@end

@implementation PhotoBroswer

#pragma mark - 初始化
- (instancetype)initWithPresentingVC:(UIViewController *)viewController delegate:(id<PhotoBroswerDelegate>)delegate {
    self.presentingVC = viewController;
    self.photoBroswerDelegate = delegate;
    self.photoSpacing = 30;
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

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    
    //立即加载collectionView
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self.collectionView layoutIfNeeded];
    //取当前应显示的cell，完善转场动画器的设置
    PhotoBrowserCell *cell = (PhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        // TODO
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy views
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _flowLayout = [[PhotoBroswerLayout alloc] init];
        _flowLayout.minimumLineSpacing = _photoSpacing;
        _flowLayout.itemSize = self.view.bounds.size;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        //设置减速速率
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[PhotoBrowserCell class] forCellWithReuseIdentifier: NSStringFromClass([PhotoBrowserCell class])];
        
    }
    return _collectionView;
}

- (UIView *)relateView {
    return [self.photoBroswerDelegate photoBroswer:self thumbnailViewForIndex:_currentIndex];
}

#pragma mark - collectionView dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoBrowserCell class]) forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - collectionView delegate


#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    //在本方法被调用时，endView和scaleView还未确定。需于viewDidLoad方法中给animator赋值endView
    // TODO 待赋值
    ScaleAnimator *animator = [[ScaleAnimator alloc] initWithStartView:nil endView:nil scaleView:nil];
    
    // TODO
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    PhotoBrowserCell *cell = (PhotoBrowserCell *)self.collectionView.visibleCells.firstObject;
    if (!cell) {
        return nil;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    // TODO
    //    imageView.contentMode =
    imageView.clipsToBounds = YES;
    return [[ScaleAnimator alloc] initWithStartView:cell.imageView endView:self.relateView scaleView:imageView];
}

//- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
//    
//    //TODO
//    
//}

#pragma mark - PhotoBrowserCellDelegate
- (void)photoBroswerCellDidSingleTap:(PhotoBrowserCell *)cell {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
































