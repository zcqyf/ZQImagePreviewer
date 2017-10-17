//
//  YGReadManager.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/17.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CURRENT_BOOK_MODEL [YGReadManager sharedManager].bookModel
#define CURRENT_RECORD [YGReadManager sharedManager].bookModel.record

@protocol YGReadManagerDelegate;

@interface YGReadManager : NSObject

+ (YGReadManager *)sharedManager;

+ (CGRect)readViewBounds;

@property (nonatomic,strong) NSURL *resourceURL;
@property (nonatomic,strong) YGBookModel *bookModel;
@property (nonatomic,weak) id<YGReadManagerDelegate> rmDelegate;

//获取对于章节页码的radViewController
- (YGReadViewController *)readViewWithChapter:(NSInteger *)chapter
                                          page:(NSInteger *)page
                                       pageUrl:(NSString *)pageUrl;

- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page;//跳转到指定章节（上一章，下一章，slider，目录）
- (void)readViewJumpToNote:(YGNoteModel *)note;//跳转到指定笔记，因为是笔记是基于位置查找的，使用page查找可能出错
- (void)readViewJumpToMark:(YGMarkModel *)mark;//跳转到指定书签，因为是书签是基于位置查找的，使用page查找可能出错
- (void)configReadFontSize:(BOOL)plus;//设置字体大小;
- (void)configReadFontName:(NSString *)fontName;//设置字体;

- (void)configReadTheme:(UIColor *)theme;//设置阅读背景
- (void)updateReadModelWithChapter:(NSInteger)chapter page:(NSInteger)page;//更新阅读记录
- (void)closeReadView;//关闭阅读器
- (void)addBookMark;//添加或删除书签
- (void)addNoteModel:(YGNoteModel *)noteModel;//添加笔记

@end

@protocol YGReadManagerDelegate <NSObject>
@optional
- (void)readViewDidClickCloseButton;//点击关闭按钮
- (void)readViewFontDidChanged;//字体改变
- (void)readViewThemeDidChanged;//主题改变
- (void)readViewEffectDidChanged;//翻页效果改变
- (void)readViewDidAddNoteSuccess;//添加笔记
- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page;//跳转到章节
- (void)readViewDidUpdateReadRecord;//更新阅读进度
@end
