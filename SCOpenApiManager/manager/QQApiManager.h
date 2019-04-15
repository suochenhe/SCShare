//
//  QQApiManager.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "SCUserModel.h"
#import "SCOpenApiProtocol.h"

@interface QQApiManager : NSObject<TencentSessionDelegate,QQApiInterfaceDelegate>

@property(nonatomic,strong)SCUserModel *userInfo;
@property (nonatomic, weak) id<SCOpenApiProtocol> delegate;

@property (nonatomic,strong) TencentOAuth *tencentOAuth;

+ (instancetype)sharedManager;

/**
 *  分享消息
 *
 *  @param toQzone Yes分享到qzone  NO 分享到QQ
 */
+ (void)shareToQZone:(BOOL)toQzone;

+ (void)login;
+ (void)logout;
+ (BOOL)isQQAuthorize;
@end
