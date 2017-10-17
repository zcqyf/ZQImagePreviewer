//
//  YGBookModel.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/16.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "YGBookModel.h"

@implementation LPPBookInfoModel

//NSString *const kLPPBookInfoModelRootDocumentUrlEncodeKey = @"rootDocumentUrl";
//NSString *const kLPPBookInfoModelOEBPSUrlEncodeKey = @"OEBPSUrl";
//NSString *const kLPPBookInfoModelCoverEncodeKey = @"cover";
//NSString *const kLPPBookInfoModelTitleEncodeKey = @"title";
//NSString *const kLPPBookInfoModelCreatorEncodeKey = @"creator";
//NSString *const kLPPBookInfoModelSubjectEncodeKey = @"subject";
//NSString *const kLPPBookInfoModelDescripEncodeKey = @"descrip";
//NSString *const kLPPBookInfoModelDateEncodeKey = @"date";
//NSString *const kLPPBookInfoModelTypeEncodeKey = @"type";
//NSString *const kLPPBookInfoModelFormatEncodeKey = @"format";
//NSString *const kLPPBookInfoModelIdentifierEncodeKey = @"identifier";
//NSString *const kLPPBookInfoModelSourceEncodeKey = @"source";
//NSString *const kLPPBookInfoModelRelationEncodeKey = @"relation";
//NSString *const kLPPBookInfoModelCoverageEncodeKey = @"coverage";
//NSString *const kLPPBookInfoModelRightsEncodeKey = @"rights";
//
//- (void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:self.rootDocumentUrl forKey:kLPPBookInfoModelRootDocumentUrlEncodeKey];
//    [aCoder encodeObject:self.OEBPSUrl forKey:kLPPBookInfoModelOEBPSUrlEncodeKey];
//    [aCoder encodeObject:self.cover forKey:kLPPBookInfoModelCoverEncodeKey];
//    [aCoder encodeObject:self.title forKey:kLPPBookInfoModelTitleEncodeKey];
//    [aCoder encodeObject:self.creator forKey:kLPPBookInfoModelCreatorEncodeKey];
//    [aCoder encodeObject:self.subject forKey:kLPPBookInfoModelSubjectEncodeKey];
//    [aCoder encodeObject:self.descrip forKey:kLPPBookInfoModelDescripEncodeKey];
//    [aCoder encodeObject:self.date forKey:kLPPBookInfoModelDateEncodeKey];
//    [aCoder encodeObject:self.type forKey:kLPPBookInfoModelTypeEncodeKey];
//    [aCoder encodeObject:self.format forKey:kLPPBookInfoModelFormatEncodeKey];
//    [aCoder encodeObject:self.identifier forKey:kLPPBookInfoModelIdentifierEncodeKey];
//    [aCoder encodeObject:self.source forKey:kLPPBookInfoModelSourceEncodeKey];
//    [aCoder encodeObject:self.relation forKey:kLPPBookInfoModelRelationEncodeKey];
//    [aCoder encodeObject:self.coverage forKey:kLPPBookInfoModelCoverageEncodeKey];
//    [aCoder encodeObject:self.rights forKey:kLPPBookInfoModelRightsEncodeKey];
//}
//- (id)initWithCoder:(NSCoder *)aDecoder{
//    self = [super init];
//    if (self) {
//        self.rootDocumentUrl = [aDecoder decodeObjectForKey:kLPPBookInfoModelRootDocumentUrlEncodeKey];
//        self.OEBPSUrl = [aDecoder decodeObjectForKey:kLPPBookInfoModelOEBPSUrlEncodeKey];
//        self.cover = [aDecoder decodeObjectForKey:kLPPBookInfoModelCoverEncodeKey];
//        self.title = [aDecoder decodeObjectForKey:kLPPBookInfoModelTitleEncodeKey];
//        self.creator = [aDecoder decodeObjectForKey:kLPPBookInfoModelCreatorEncodeKey];
//        self.subject = [aDecoder decodeObjectForKey:kLPPBookInfoModelSubjectEncodeKey];
//        self.descrip = [aDecoder decodeObjectForKey:kLPPBookInfoModelDescripEncodeKey];
//        self.date = [aDecoder decodeObjectForKey:kLPPBookInfoModelDateEncodeKey];
//        self.type = [aDecoder decodeObjectForKey:kLPPBookInfoModelTypeEncodeKey];
//        self.format = [aDecoder decodeObjectForKey:kLPPBookInfoModelFormatEncodeKey];
//        self.identifier = [aDecoder decodeObjectForKey:kLPPBookInfoModelIdentifierEncodeKey];
//        self.source = [aDecoder decodeObjectForKey:kLPPBookInfoModelSourceEncodeKey];
//        self.relation = [aDecoder decodeObjectForKey:kLPPBookInfoModelRelationEncodeKey];
//        self.coverage = [aDecoder decodeObjectForKey:kLPPBookInfoModelCoverageEncodeKey];
//        self.rights = [aDecoder decodeObjectForKey:kLPPBookInfoModelRightsEncodeKey];
//    }
//    return self;
//}
//
//- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
//    
//}

@end

@interface YGBookModel ()

//  外露只读，extension扩展覆盖，可读写
//@property (nonatomic,strong) NSMutableArray<YGChapterModel *> *chapters;//章节
//@property (nonatomic,copy) NSArray <YGChapterModel *> *chapterContainNotes;//包含笔记的章节
//@property (nonatomic,copy) NSArray <YGChapterModel *> *chapterContainMarks;//包含笔记的章节

@end

@implementation YGBookModel

//NSString *const kXDSBookModelBookBasicInfoEncodeKey = @"bookBasicInfo";
//NSString *const kXDSBookModelResourceEncodeKey = @"resource";
//NSString *const kXDSBookModelContentEncodeKey = @"content";
//NSString *const kXDSBookModelBookTypeEncodeKey = @"bookType";
//NSString *const kXDSBookModelChaptersEncodeKey = @"chapters";
//NSString *const kXDSBookModelRecordEncodeKey = @"record";

- (instancetype)initWithContent:(NSString *)content{
    self = [super init];
    if (self) {
        _content = content;
        NSMutableArray *charpter = [NSMutableArray array];
        [YGReadOperation separateChapter:&charpter content:content];
        _chapters = charpter;
        _record = [[YGRecordModel alloc] init];
//        _record.chapterModel = charpter.firstObject;
//        _record.location = 0;
//        _bookType = LPPEBookTypeTxt;
    }
    return self;
}
- (instancetype)initWithePub:(NSString *)ePubPath{
    self = [super init];
    if (self) {
        _bookBasicInfo = [[LPPBookInfoModel alloc] init];
//        _chapters = [XDSReadOperation ePubFileHandle:ePubPath bookInfoModel:_bookBasicInfo];
        _record = [[YGRecordModel alloc] init];
//        _record.chapterModel = _chapters.firstObject;
//        _record.location = 0;
//        _bookType = LPPEBookTypeEpub;
    }
    return self;
}
+ (void)showCoverPage {
    
}














































@end
