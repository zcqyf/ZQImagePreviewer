//
//  ViewController.m
//  ImagePreviewer
//
//  Created by qing on 2017/9/30.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "ViewController.h"
#import "PhotoBroswer.h"
#import "CollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebImage.h"

#import "PhotoBrowserProgressView.h"
#import "PhotoBrowser.h"
#import "ModalAnimationDelegate.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, PhotoBroswerDelegate>



@property (nonatomic,strong) NSArray *thumbnailImageUrls;

@property (nonatomic,strong) NSArray *highQualityImageUrls;

@property (nonatomic,strong) UIImageView *imgView;

@property (nonatomic,assign) NSInteger index;

@property (nonatomic,strong) PhotoBrowserProgressView *progressView;

@property (nonatomic,strong) ModalAnimationDelegate *modalAnimationDelegate;

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
    
    _modalAnimationDelegate = [ModalAnimationDelegate new];
    
//    _index = 0;
//
//    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    [self.view addSubview:_imgView];
//    _imgView.center = self.view.center;
//
//    _progressView = [PhotoBrowserProgressView new];
//    [self.view addSubview:_progressView];
//    _progressView.center = self.view.center;
//    [_progressView setHidden:YES];
//
//    [self setImage];
//
//    [_imgView setUserInteractionEnabled:YES];
//
//    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
//    [_imgView addGestureRecognizer:leftSwipe];
//
//    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//    [_imgView addGestureRecognizer:rightSwipe];
    
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
    [[PhotoBroswer alloc] showWithPresentingVC:self delegate:self index:indexPath.item];
}

#pragma mark - PhotoBroswerDelegate
- (NSInteger)numberOfPhotosInPhotoBroswer:(PhotoBroswer *)photoBrowser {
    return self.thumbnailImageUrls.count;
}

/// 缩放起始视图
- (UIView *)photoBrowser:(PhotoBroswer *)photoBrowser thumbnailViewForIndex:(NSInteger)index {
    return [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

/// 图片加载前的placeholder
- (UIImage *)photoBrowser:(PhotoBroswer *)photoBrowser thumbnailImageForIndex:(NSInteger)index {
    CollectionViewCell *cell = (CollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    // 取thumbnailImage
    return cell.imageView.image;
}

/// 高清图
- (NSURL *)photoBrowser:(PhotoBroswer *)photoBrowser highQualityUrlForIndex:(NSInteger)index {
    return [NSURL URLWithString:self.highQualityImageUrls[index]];
}

//原图
//- (NSString *)photoBrowser:(PhotoBroswer *)photoBrowser rawUrlStringForIndex:(NSInteger)index {
//    return self.highQualityImageUrls[index];
//}

- (void)photoBrowser:(PhotoBroswer *)photoBrowser didLongPressForIndex:(NSInteger)index image:(UIImage *)image {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"保存图片");
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [actionSheet addAction:saveAction];
    [actionSheet addAction:cancelAction];
    [photoBrowser presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
