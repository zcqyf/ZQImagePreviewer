//
//  YGRecordModel.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/16.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGRecordModel : NSObject <NSCopying>

@property (nonatomic,strong) YGChapterModel *chapterModel;  //阅读的章节
@property (nonatomic) NSInteger location;    //章节中的位置
@property (nonatomic, assign) NSInteger currentChapter; //阅读的章节

@property (nonatomic, readonly) NSInteger currentPage;    //阅读的页数
@property (nonatomic, readonly) NSInteger totalPage;  //该章总页数
@property (nonatomic, readonly) NSInteger totalChapters;  //总章节数

@end
