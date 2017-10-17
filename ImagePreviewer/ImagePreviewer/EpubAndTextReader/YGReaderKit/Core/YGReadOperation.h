//
//  YGReadOperation.h
//  ImagePreviewer
//
//  Created by qing on 2017/10/17.
//  Copyright © 2017年 YG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGReadOperation : NSObject

+ (void)separateChapter:(NSMutableArray **)chapters content:(NSString *)content;

/**
 * ePub格式处理
 * 返回章节信息数组
 */
+ (NSMutableArray *)ePubFileHandle:(NSString *)path bookInfoModel:(LPPBookInfoModel *)bookInfoModel;

@end
