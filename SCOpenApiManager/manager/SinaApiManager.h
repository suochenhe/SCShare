//
//  SinaApiManager.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "SCUserModel.h"
#import "SCOpenApiProtocol.h"

@interface SinaApiManager : NSObject<WeiboSDKDelegate,WBHttpRequestDelegate>

@property(nonatomic,strong)SCUserModel *userInfo;

@property (nonatomic, weak) id<SCOpenApiProtocol> delegate;


+ (instancetype)sharedManager;

//是否授权
+ (BOOL)isSinaAuthorize;
//授权
+ (void)login;
//取消授权
+ (void)logout;

//新浪分享
+ (void)sinaShare;
@end
