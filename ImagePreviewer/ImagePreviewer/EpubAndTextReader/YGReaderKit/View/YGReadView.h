//
//  YGReadView.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/17.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XDSReadViewControllerDelegate;

@interface YGReadView : UIView

- (instancetype)initWithFrame:(CGRect)frame chapterNum:(NSInteger)chapterNum pageNum:(NSInteger)pageNum;

- (void)cancelSelected;


@property (nonatomic,strong) id<XDSReadViewControllerDelegate> rvDelegate;

@end
