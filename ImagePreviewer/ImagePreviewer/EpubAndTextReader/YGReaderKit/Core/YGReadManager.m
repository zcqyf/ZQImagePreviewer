//
//  YGReadManager.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/17.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "YGReadManager.h"

@implementation YGReadManager

static YGReadManager *readManager;

+ (YGReadManager *)sharedManager{
    if (readManager == nil) {
        readManager = [[self alloc] init];
    }
    return readManager;
}

+ (id)allocWithZone:(NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readManager = [super allocWithZone:zone];
    });
    return readManager;
}

+ (CGRect)readViewBounds {
    CGRect bounds = CGRectMake(kReadViewMarginTop,
                               kReadViewMarginLeft,
                               DEVICE_MAIN_SCREEN_WIDTH_XDSR-kReadViewMarginLeft-kReadViewMarginRight,
                               DEVICE_MAIN_SCREEN_HEIGHT_XDSR-kReadViewMarginTop-kReadViewMarginBottom);
    return bounds;
}
//MARK: - //获取对于章节页码的radViewController
- (YGReadViewController *)readViewWithChapter:(NSInteger *)chapter
                                          page:(NSInteger *)page
                                       pageUrl:(NSString *)pageUrl{
    
    YGChapterModel *currentChapterModel = _bookModel.chapters[*chapter];
    if (currentChapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
        if (currentChapterModel == CURRENT_RECORD.chapterModel) {
            *page = CURRENT_RECORD.currentPage;
        }
    }
    
    if (*page < 0){
        *page = currentChapterModel.pageCount - 1;
    }
    
    YGReadViewController *readView = [[YGReadViewController alloc] init];
    readView.chapterNum = *chapter;
    readView.pageNum = *page;
    readView.pageUrl = pageUrl;
    return readView;
}

- (void)loadContentInChapter:(NSInteger)chapter{
    YGChapterModel *chapterModel = _bookModel.chapters[chapter];
    if (!chapterModel.chapterAttributeContent) {
        [CURRENT_BOOK_MODEL loadContentInChapter:chapterModel];
    }
}
//MARK: - 跳转到指定章节（上一章，下一章，slider，目录）
- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page{
    //跳转到指定章节
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewJumpToChapter:page:)]) {
        [self.rmDelegate readViewJumpToChapter:chapter page:page];
    }
    //更新阅读记录
    [self updateReadModelWithChapter:chapter page:page];
}
//MARK: - 跳转到指定笔记，因为是笔记是基于位置查找的，使用page查找可能出错
- (void)readViewJumpToNote:(YGNoteModel *)note{
    YGChapterModel *currentChapterModel = _bookModel.chapters[note.chapter];
    if (currentChapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    }
    [self readViewJumpToChapter:note.chapter page:note.page];
}

//MARK: - 跳转到指定书签，因为是书签是基于位置查找的，使用page查找可能出错
- (void)readViewJumpToMark:(YGMarkModel *)mark{
    
    YGChapterModel *currentChapterModel = _bookModel.chapters[mark.chapter];
    if (currentChapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    }
    
    [self readViewJumpToChapter:mark.chapter page:mark.page];
}
//MARK: - 设置字体
- (void)configReadFontSize:(BOOL)plus{
    if ([YGReadConfig shareInstance].currentFontSize < 1) {
        [YGReadConfig shareInstance].currentFontSize = [XDSReadConfig shareInstance].cachefontSize;
    }
    if (plus) {
        [YGReadConfig shareInstance].currentFontSize++;
        if (floor([XDSReadConfig shareInstance].currentFontSize) >= floor(kXDSReadViewMaxFontSize)) {
            [XDSReadConfig shareInstance].currentFontSize = kXDSReadViewMaxFontSize;
        }
    }else{
        [XDSReadConfig shareInstance].currentFontSize--;
        if (floor([XDSReadConfig shareInstance].currentFontSize) <= floor(kXDSReadViewMinFontSize)){
            [XDSReadConfig shareInstance].currentFontSize = kXDSReadViewMinFontSize;
        }
    }
    
    if (CURRENT_RECORD.chapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:CURRENT_RECORD.chapterModel];
    }
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewFontDidChanged)]) {
        [self.rmDelegate readViewFontDidChanged];
    }
}

- (void)configReadFontName:(NSString *)fontName{
    
    //更新字体信息
    [[XDSReadConfig shareInstance] setCurrentFontName:fontName];
    
    //重新加载章节内容
    XDSChapterModel *currentChapterModel = CURRENT_RECORD.chapterModel;
    [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewFontDidChanged)]) {
        [self.rmDelegate readViewFontDidChanged];
    }
}

- (void)configReadTheme:(UIColor *)theme{
    [XDSReadConfig shareInstance].currentTheme = theme;
    
    XDSChapterModel *currentChapterModel = CURRENT_RECORD.chapterModel;
    [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewThemeDidChanged)]) {
        [self.rmDelegate readViewThemeDidChanged];
    }
}
//MARK: - 更新阅读记录
-(void)updateReadModelWithChapter:(NSInteger)chapter page:(NSInteger)page{
    if (chapter < 0) {
        chapter = 0;
    }
    if (page < 0) {
        page = 0;
    }
    _bookModel.record.chapterModel = _bookModel.chapters[chapter];
    _bookModel.record.location = [_bookModel.record.chapterModel.pageLocations[page] integerValue];
    _bookModel.record.currentChapter = chapter;
    [XDSBookModel updateLocalModel:_bookModel url:_resourceURL];
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewDidUpdateReadRecord)]) {
        [self.rmDelegate readViewDidUpdateReadRecord];
    }
}


//MARK: - 关闭阅读器
- (void)closeReadView{
    
    //release memery 释放内存
    self.bookModel = nil;
    self.resourceURL = nil;
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewDidClickCloseButton)]) {
        [self.rmDelegate readViewDidClickCloseButton];
    }
}

//MARK: - 添加或删除书签
- (void)addBookMark{
    XDSMarkModel *markModel = [[XDSMarkModel alloc] init];
    XDSChapterModel *currentChapterModel = _bookModel.record.chapterModel;
    NSInteger currentPage = _bookModel.record.currentPage;
    NSInteger currentChapter = _bookModel.record.currentChapter;
    markModel.date = [NSDate date];
    markModel.content = currentChapterModel.pageStrings[currentPage];
    markModel.chapter = currentChapter;
    markModel.locationInChapterContent = [currentChapterModel.pageLocations[currentPage] integerValue];
    [CURRENT_BOOK_MODEL addMark:markModel];
}

- (void)addNoteModel:(YGNoteModel *)noteModel{
    noteModel.chapter = CURRENT_RECORD.currentChapter;
    [CURRENT_BOOK_MODEL addNote:noteModel];
    
    //    //绘制笔记下划线
    //    [CURRENT_BOOK_MODEL loadContentInChapter:_bookModel.record.chapterModel];
    
    //    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewDidAddNoteSuccess)]) {
    //        [self.rmDelegate readViewDidAddNoteSuccess];
    //    }
}

@end
