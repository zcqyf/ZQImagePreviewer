//
//  UIImageView+WebImage.m
//  ImagePreviewer
//
//  Created by qing on 2017/10/10.
//  Copyright © 2017年 YG. All rights reserved.
//

#import "UIImageView+WebImage.h"

@implementation UIImageView (WebImage)

- (void)zq_setImageWithUrl:(NSString *)urlString {
    //  创建下载图片url
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    
    //  创建网络请求配置类
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //  创建网络会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue new]];
    //  创建请求并设置缓存策略以及超时时长
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:30.f];
    //  configuration.requestCachePolicy =
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"下载失败，error:%@",error);
            return;
        }
        //  下载完成后获取数据，此时已经自动缓存到本地，下次会直接从本地缓存获取，不再进行网络请求
        if (!location) {
            NSLog(@"下载失败，location is nil");
            return;
        }
        NSData *data = [NSData dataWithContentsOfURL:location];
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置图片
            self.image = [UIImage imageWithData:data];
        });
    }];
    //  启动下载任务
    [task resume];
}

@end
