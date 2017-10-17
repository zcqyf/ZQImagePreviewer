//
//  YGReadOperation.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/17.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "YGReadOperation.h"

@implementation YGReadOperation

+ (void)separateChapter:(NSMutableArray **)chapters content:(NSString *)content {
    
    [*chapters removeAllObjects];
    NSString *regPattern = @"第[0-9一二三四五六七八九十百千]*[章回].*";
    NSError* error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regPattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* match = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
    
    if (match.count != 0){
        __block NSRange lastRange = NSMakeRange(0, 0);
        [match enumerateObjectsUsingBlock:^(NSTextCheckingResult *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj range];
            NSInteger local = range.location;
            
            YGChapterModel *model = [[YGChapterModel alloc] init];
            
            if (idx == 0) {
                model.chapterName = @"开始";
                NSUInteger len = local;
                model.originContent = [content substringWithRange:NSMakeRange(0, len)];
                
            }
            if (idx > 0 ) {
                model.chapterName = [content substringWithRange:lastRange];
                NSUInteger len = local-lastRange.location;
                model.originContent = [content substringWithRange:NSMakeRange(lastRange.location, len)];
            }
            if (idx == match.count-1) {
                model.chapterName = [content substringWithRange:range];
                model.originContent = [content substringWithRange:NSMakeRange(local, content.length-local)];
            }
            
            YGCatalogueModel *catalogueModel = [[YGCatalogueModel alloc] init];
            catalogueModel.catalogueName = model.chapterName;
            catalogueModel.link = @"";
            catalogueModel.catalogueId = @"";
            catalogueModel.chapter = (*chapters).count;
            model.catalogueModelArray = @[catalogueModel];
            
            [*chapters addObject:model];
            lastRange = range;
        }];
    }else{
        YGChapterModel *model = [[YGChapterModel alloc] init];
        model.originContent = content;
        [*chapters addObject:model];
    }
}



@end
