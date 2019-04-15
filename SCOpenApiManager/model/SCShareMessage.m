//
//  SCShareMessage.m
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SCShareMessage.h"
#import "OpenApiConstant.h"

@implementation SCShareMessage
+ (instancetype)sharedMessage{
    static SCShareMessage *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
+ (void)clearMessage{
    [[SCShareMessage sharedMessage] clearMessage];
}

+ (void)setAppMessage{
    [[SCShareMessage sharedMessage] setMessageWithType:SCShareMessageTypeApp title:nil content:nil image:nil urlStr:nil mediaUrlStr:nil];
}

+ (void)setMessageWithTitle:(NSString *)title content:(NSString *)content image:(UIImage *)image urlStr:(NSString *)urlStr{
    [self clearMessage];
    [[SCShareMessage sharedMessage] setMessageWithType:SCShareMessageTypeMessage title:title content:content image:image urlStr:urlStr mediaUrlStr:nil];
}
+ (void)setMediaMessageWithTitle:(NSString *)title content:(NSString *)content image:(UIImage *)image mediaUrlStr:(NSString *)mediaUrlStr{
    [self clearMessage];
    [[SCShareMessage sharedMessage] setMessageWithType:SCShareMessageTypeMessage title:title content:content image:image urlStr:nil mediaUrlStr:mediaUrlStr];
}

- (void)clearMessage{
    _title = nil;
    _content = nil;
    _thumbnailData = nil;
    _urlStr = nil;
    
    _mediaUrlStr = nil;
}

- (void)setMessageWithType:(SCShareMessageType)type title:(NSString *)title content:(NSString *)content image:(UIImage *)image urlStr:(NSString *)urlStr mediaUrlStr:(NSString *)mediaUrlStr{
    NSData *thumbnailData = nil;
    if (image == nil) {//qq空间分享视频，无图分享会（系统繁忙，重试）
        image = AppIcon;
    }
    
    thumbnailData = UIImageJPEGRepresentation(image,1);
    NSLog(@" imagesize %@",@(thumbnailData.length));
    
    UIImage *tempImage = image;
    if (thumbnailData.length > 32 * 1024){
        tempImage = [image scalingToSize:CGSizeMake(200, 200)];
        thumbnailData = UIImageJPEGRepresentation(tempImage, 0.9);
    }
    
    NSLog(@" imagesize %@",@(thumbnailData.length));

    _shareType = type;
    _title = title;
    _content = content;
    _thumbnailData = thumbnailData;
    _urlStr = urlStr;
    _mediaUrlStr = mediaUrlStr;
}
@end
