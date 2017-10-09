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

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, PhotoBroswerDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *thumbnailImageUrls;

@property (nonatomic,strong) NSArray *highQualityImageUrls;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    NSInteger colCount = 3;
    NSInteger rowCount = 3;
    
    CGFloat xMargin = 60.0;
    CGFloat interitemSpacing = 10.0;
    CGFloat width = self.view.bounds.size.width - xMargin * 2;
    CGFloat itemSize = (width - 2 * interitemSpacing) /(CGFloat)colCount;
    
    CGFloat lineSpacing = 10.0;
    CGFloat height = itemSize * (CGFloat)rowCount + lineSpacing * 2;
    CGFloat y = 60.0;
    
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
    
    PhotoBroswer *photoBrowser = [[PhotoBroswer alloc] initWithPresentingVC:self delegate:self];
    [photoBrowser show:indexPath.item];
}

#pragma mark - PhotoBroswerDelegate
- (NSInteger)numberOfPhotosInPhotoBroswer:(PhotoBroswer *)photoBrowser {
    return self.thumbnailImageUrls.count;
}

/**
 缩放起始图
 */
- (UIView *)photoBrowser:(PhotoBroswer *)photoBrowser thumbnailViewForIndex:(NSInteger)index {
    return [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

/**
 图片加载前的placeholder
 */
- (UIImage *)photoBrowser:(PhotoBroswer *)photoBrowser thumbnailImageForIndex:(NSInteger)index {
    CollectionViewCell *cell = (CollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.imageView.image;
}

/**
 高清图
 */
- (NSString *)photoBrowser:(PhotoBroswer *)photoBrowser highQualityUrlStringForIndex:(NSInteger)index {
    return self.highQualityImageUrls[index];
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
