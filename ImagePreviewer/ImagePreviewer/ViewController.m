//
//  ViewController.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "PhotoBrowserProgressView.h"
#import "PhotoBrowser.h"
#import "ImageScaleAnimator.h"


@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, PhotoBrowserDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *thumbnailImageUrls;

@property (nonatomic,strong) NSArray *highQualityImageUrls;

@property (nonatomic,strong) UIImageView *imgView;

@property (nonatomic,assign) NSInteger index;

@property (nonatomic,strong) PhotoBrowserProgressView *progressView;

@property (nonatomic,strong) UIImageView *scaleImageView;

@property (nonatomic,strong) UIImageView *startImageView;

@property (nonatomic,strong) UIImageView *endImageView;

@property (nonatomic,strong) PhotoBrowser *photoBrowser;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _thumbnailImageUrls = @[@"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                            @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg",
                            @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                            @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                            @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7qjop4j20i00hw4c6.jpg",
                            @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                            @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                            @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                            @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7usmc8j20i543zngx.jpg",];
    
    _highQualityImageUrls = @[@"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                              @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg",
                              @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                              @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                              @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7qjop4j20i00hw4c6.jpg",
                              @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                              @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                              @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                              @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7usmc8j20i543zngx.jpg",];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupUI];
}

- (void)setImage {
    [_progressView setHidden:NO];
    [_imgView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:_highQualityImageUrls[_index]] placeholderImage:nil options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (expectedSize > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
                _progressView.progress = progress;
            });
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"图片加载完成");
        [_progressView setHidden:YES];
    }];
    
}

- (void)swipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        _index -= 1;
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        _index += 1;
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"UISwipeGestureRecognizerDirectionUp");
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"UISwipeGestureRecognizerDirectionDown");
    }
    
    if (_index > 8) {
        _index = 0;
    }
    if (_index < 0 ) {
        _index = 8;
    }
    
    [self setImage];
}

- (void)setupUI {
    
    
    NSInteger colCount = 3;
    NSInteger rowCount = 3;
    
    CGFloat xMargin = 60.0;
    CGFloat interitemSpacing = 10.0;
    CGFloat width = self.view.bounds.size.width - xMargin * 2;
    CGFloat itemSize = (width - 2 * interitemSpacing) /(CGFloat)colCount;
    
    CGFloat lineSpacing = 10.0;
    CGFloat height = itemSize * (CGFloat)rowCount + lineSpacing * 2;
    CGFloat y = (CGRectGetHeight(self.view.bounds) - height) / 2;
    
    CGRect frame = CGRectMake(xMargin, y, width, height);
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = interitemSpacing;
    layout.itemSize = CGSizeMake(itemSize, itemSize);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class])];
    
    [self.view addSubview:_collectionView];
    
    [_collectionView reloadData];
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (UIImageView *)scaleImageView {
    if (!_scaleImageView) {
        _scaleImageView = [UIImageView new];
    }
    return _scaleImageView;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.endImageView = _photoBrowser.endImageView;
    self.scaleImageView.image = self.startImageView.image;
    ImageScaleAnimator *scaleAnimator = [[ImageScaleAnimator alloc] initWithStartView:self.startImageView scaleView:self.scaleImageView endView:self.endImageView isPresented:YES];
    return scaleAnimator;
}

// 3. Implement the methods to supply proper objects.
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.scaleImageView.image = self.endImageView.image;
    ImageScaleAnimator *scaleAnimator = [[ImageScaleAnimator alloc] initWithStartView:self.endImageView scaleView:self.scaleImageView endView:self.startImageView isPresented:NO];
    return scaleAnimator;
}

//
//-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
//    return self.transitionController.interacting ? self.transitionController : nil;
//}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnailImageUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class]) forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_thumbnailImageUrls[indexPath.row]]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    _photoBrowser = [PhotoBrowser new];
    _photoBrowser.presentingVC = self;
    _photoBrowser.delegate = self;

    _photoBrowser.imageUrls = self.highQualityImageUrls;
    [_photoBrowser showWithIndex:indexPath.item];
    
}

#pragma mark - PhotoBrowserDelegate
- (void)photoBrowser:(PhotoBrowser *)photoBrowser dismissAtIndex:(NSInteger)index {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)photoBrowser:(PhotoBrowser *)photoBrowser thumbnailViewForIndex:(NSInteger)index {
    return [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

#pragma mark - PhotoBroswerDelegate

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
