//
//  SCShareManager.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "SCShareMessage.h"
#import "SCUserModel.h"
#import "SCOpenApiProtocol.h"

@interface SCOpenApiManager : NSObject<SCOpenApiProtocol>

+ (void)registSinaWeChatAndQQ;
+ (BOOL)handleOpenURL:(NSURL *)url;

//单例对象
+ (instancetype)sharedManager;

+ (BOOL)isQQInstalled;

+ (BOOL)isWeChatInstalled;


+ (SCUserModel *)userInfoWithPlatform:(SCOpenPlatformType)platformType;

+ (void)shareToPlatform:(SCOpenPlatformType)platformType;
//viewController 只有微信需要
+ (void)loginOnPlatform:(SCOpenPlatformType)platformType delegate:(id<SCOpenApiProtocol>)delegate viewController:(UIViewController *)viewController;
+ (void)loginOutPlatform:(SCOpenPlatformType)platformType delegate:(id<SCOpenApiProtocol>)delegate;
@end
