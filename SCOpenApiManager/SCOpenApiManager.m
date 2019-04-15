//
//  SCShareManager.m
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SCOpenApiManager.h"
#import "SinaApiManager.h"
#import "WeChatApiManager.h"
#import "QQApiManager.h"
#import "OpenApiConstant.h"

@interface SCOpenApiManager ()
@property (nonatomic,copy)NSString *sinaToken;
@property (nonatomic,copy)NSString *sinaUserId;
@property (nonatomic,copy)NSString *sinaRefreshToken;

@property (nonatomic,copy)NSString *weChatToken;
@property (nonatomic,copy)NSString *qqToken;
@end
@implementation SCOpenApiManager

+ (instancetype)sharedManager{
    static SCOpenApiManager *instance;
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

+ (void)registSinaWeChatAndQQ{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:SinaAppKey];
#if TARGET_IPHONE_SIMULATOR//模拟器
    
#elif TARGET_OS_IPHONE//真机
    [WXApi registerApp:WeChatAppID];
#endif
    
    [self configDirectory:SCOpenApiDataDirectory];
}

+ (BOOL)handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] || [WeiboSDK handleOpenURL:url delegate:[SinaApiManager sharedManager]] || [WXApi handleOpenURL:url delegate:[WeChatApiManager sharedManager]] || [QQApiInterface handleOpenURL:url delegate:[QQApiManager sharedManager]];;
}
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication{
    if ([sourceApplication isEqualToString:SinaSourceApplication]) {
        return  [WeiboSDK handleOpenURL:url delegate:[SinaApiManager sharedManager]];
    }else if([sourceApplication isEqualToString:WeChatSourceApplication]){
        return [WXApi handleOpenURL:url delegate:[WeChatApiManager sharedManager]];
    }else{
        return [TencentOAuth HandleOpenURL:url];
    }
    
//    if ([sourceApplication isEqualToString:SinaSourceApplication]) {
//        return  [WeiboSDK handleOpenURL:url delegate:nil];
//    }else if([sourceApplication isEqualToString:WeChatSourceApplication]){
//        return [WXApi handleOpenURL:url delegate:nil];
//    }else{
//        return [TencentOAuth HandleOpenURL:url];
//    }
}

+ (BOOL)isQQInstalled{
    return [TencentOAuth iphoneQQInstalled];
}

+ (BOOL)isWeChatInstalled{
    return [WXApi isWXAppInstalled];
}

+ (SCUserModel *)userInfoWithPlatform:(SCOpenPlatformType)platformType{
    SCUserModel *info = nil;
    if (platformType == SCOpenPlatformTypeSina) {
        info =  [SinaApiManager sharedManager].userInfo;
    }else if (platformType == SCOpenPlatformTypeQQ){
        info =  [QQApiManager sharedManager].userInfo;
    }else if (platformType == SCOpenPlatformTypeWeChat){
        info =  [WeChatApiManager sharedManager].userInfo;
    }
    return info;
}

+ (void)shareToPlatform:(SCOpenPlatformType)platformType{
    if (platformType == SCOpenPlatformTypeSina) {
        [SinaApiManager sharedManager].delegate = [SCOpenApiManager sharedManager];
        [SinaApiManager sinaShare];
    }else if (platformType == SCOpenPlatformTypeQQ){
        [QQApiManager sharedManager].delegate = [SCOpenApiManager sharedManager];
        [QQApiManager shareToQZone:NO];
    }else if (platformType == SCOpenPlatformTypeQzone){
        [QQApiManager sharedManager].delegate = [SCOpenApiManager sharedManager];
        [QQApiManager shareToQZone:YES];
    }else if (platformType == SCOpenPlatformTypeWeChat){
        [WeChatApiManager sharedManager].delegate = [SCOpenApiManager sharedManager];
        [WeChatApiManager shareWithScenes:WXSceneSession];
    }else if (platformType == SCOpenPlatformTypeWeChatCirle){
        [WeChatApiManager sharedManager].delegate = [SCOpenApiManager sharedManager];
        [WeChatApiManager shareWithScenes:WXSceneTimeline];
    }
}

+ (void)loginOnPlatform:(SCOpenPlatformType)platformType delegate:(id<SCOpenApiProtocol>)delegate viewController:(UIViewController *)viewController{
    if (platformType == SCOpenPlatformTypeSina) {
        [SinaApiManager sharedManager].delegate = delegate;
        [SinaApiManager login];
    }else if (platformType == SCOpenPlatformTypeQQ){
        [QQApiManager sharedManager].delegate = delegate;
        [QQApiManager login];
    }else if (platformType == SCOpenPlatformTypeWeChat){
        [WeChatApiManager sharedManager].delegate = delegate;
        [WeChatApiManager loginWithViewController:viewController];
    }
}

+ (void)loginOutPlatform:(SCOpenPlatformType)platformType delegate:(id<SCOpenApiProtocol>)delegate{
    if (platformType == SCOpenPlatformTypeSina) {
        [SinaApiManager sharedManager].delegate = delegate;
        [SinaApiManager logout];
    }else if (platformType == SCOpenPlatformTypeQQ){
        [QQApiManager sharedManager].delegate = delegate;
        [QQApiManager logout];
    }else if (platformType == SCOpenPlatformTypeWeChat){
        [WeChatApiManager sharedManager].delegate = delegate;
        [WeChatApiManager logout];
    }
}


#pragma mark - SCOpenApiProtocol
- (void)managerDidLoginSuccess:(BOOL)success platform:(SCOpenPlatformType)platform errorMsg:(NSString *)errorMsg{}

- (void)managerDidLogoutSuccess:(BOOL)success platform:(SCOpenPlatformType)platform errorMsg:(NSString *)errorMsg{}

- (void)managerDidGetUserInoSuccess:(BOOL)success platform:(SCOpenPlatformType)platform errorMsg:(NSString *)errorMsg{}

- (void)managerDidSendMessageSuccess:(BOOL)success errorMsg:(NSString *)errorMsg{
    NSString *message = success ? @"分享成功" : errorMsg;
    if ([message isNotEmpty]) {
        [MBProgressHUD showOnlyText:message toView:[UIApplication sharedApplication].keyWindow];
    }
}

//初始化存储目录
+ (BOOL)configDirectory:(nonnull NSString *)directory {
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    BOOL  result = YES;
    if(directory != nil && directory.length > 0){
        
        if(![defaultFileManager fileExistsAtPath:directory]){
            __autoreleasing NSError *error = nil;
            [defaultFileManager createDirectoryAtPath:directory
                          withIntermediateDirectories:YES
                                           attributes:@{NSFileProtectionKey : NSFileProtectionNone}
                                                error:&error];
            if(error){
                NSLog(@"configDirectory %@",error);
                result = NO;
            }
        }
    }else{
        result = NO;
    }
    return result;
}


@end
