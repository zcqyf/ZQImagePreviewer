//
//  YGReadConfig.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/17.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "YGReadConfig.h"

@interface YGReadConfig ()

@property (nonatomic, assign) CGFloat cachefontSize;
@property (nonatomic, copy) NSString *cacheFontName;
@property (nonatomic) CGFloat cacheLineSpace;
@property (nonatomic,strong) UIColor *cacheTextColor;
@property (nonatomic,strong) UIColor *cacheTheme;

@end

@implementation YGReadConfig

NSString *const kReadConfigEncodeKey = @"ReadConfig";
NSString *const kReadConfigFontSizeEncodeKey = @"cacheFontSize";
NSString *const kReadConfigFontNameEncodeKey = @"cacheFontName";
NSString *const kReadConfigLineSpaceEncodeKey = @"cacheLineSpace";
NSString *const kReadConfigTextColorEncodeKey = @"cacheTextColor";
NSString *const kReadConfigThemeEncodeKey = @"cacheTheme";

+ (instancetype)shareInstance{
    static YGReadConfig *readConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readConfig = [[self alloc] init];
    });
    return readConfig;
}

- (instancetype)init{
    if (self = [super init]) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kReadConfigEncodeKey];
        if (data) {
            NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
            YGReadConfig *config = [unarchive decodeObjectForKey:kReadConfigEncodeKey];
            return config;
        }
        self.cachefontSize = kXDSReadViewDefaultFontSize;
        self.cacheFontName = @"";
        self.cacheLineSpace = 10.0f;
        self.cacheTextColor = [UIColor blackColor];
        self.cacheTheme = [UIColor whiteColor];
        [YGReadConfig updateLocalConfig:self];
        
    }
    return self;
}
+ (void)updateLocalConfig:(YGReadConfig *)config{
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:config forKey:kReadConfigEncodeKey];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kReadConfigEncodeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
