//
//  WeChatApiManager.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "SCUserModel.h"
#import "SCOpenApiProtocol.h"


@interface WeChatApiManager : NSObject<WXApiDelegate>

@property(nonatomic,strong) SCUserModel *userInfo;

@property (nonatomic, weak) id<SCOpenApiProtocol> delegate;


+ (instancetype)sharedManager;
+ (void)loginWithViewController:(UIViewController *)viewController;
+ (void)updateAccessToken;
+ (void)logout;

+ (void)shareWithScenes:(enum WXScene)scene;
@end
