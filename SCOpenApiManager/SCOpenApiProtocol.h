//
//  SCOpenApiProtocol.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/23.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SCOpenPlatformType) {
    SCOpenPlatformTypeSina = 1,
    SCOpenPlatformTypeQQ,
    SCOpenPlatformTypeQzone,
    SCOpenPlatformTypeWeChat,
    SCOpenPlatformTypeWeChatCirle
};

@protocol SCOpenApiProtocol <NSObject>

@optional

- (void)managerDidLoginSuccess:(BOOL)success platform:(SCOpenPlatformType)platform errorMsg:(NSString *)errorMsg;

- (void)managerDidLogoutSuccess:(BOOL)success platform:(SCOpenPlatformType)platform errorMsg:(NSString *)errorMsg;

- (void)managerDidGetUserInoSuccess:(BOOL)success platform:(SCOpenPlatformType)platform errorMsg:(NSString *)errorMsg;

- (void)managerDidSendMessageSuccess:(BOOL)success errorMsg:(NSString *)errorMsg;

@end
