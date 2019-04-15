//
//  SCUserModel.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCUserModel : NSObject<NSCoding>
@property(nonatomic,assign,readonly) BOOL isAuthorize;

@property(nonatomic,copy) NSString *accessToken;
@property(nonatomic,copy) NSString *refreshToken;
@property(nonatomic,copy) NSString *scope;
@property(nonatomic,copy) NSString *expiresIn;
@property(nonatomic,copy) NSString *nickName;
@property(nonatomic,copy) NSString *headerUrl;

@property(nonatomic,strong) NSDate *expirationDate;

@property(nonatomic,copy) NSString *userId;//sina
@property(nonatomic,copy) NSString *code;//wechat(获取openID时使用)
@property(nonatomic,copy) NSString *openId;//qq,wechat

@property(nonatomic,copy) NSString *unionId;//wechat（用户信息）


- (void)clearInfo;
- (void)saveToPath:(NSString *)path;
+ (SCUserModel *)loadFromPath:(NSString *)path;


@end
