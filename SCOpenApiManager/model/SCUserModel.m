//
//  SCUserModel.m
//  CaiJie
//
//  Created by SuoChenhe on 15/12/22.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SCUserModel.h"

@implementation SCUserModel
//
//@property(nonatomic,assign) BOOL isAuthorize;
//
//@property(nonatomic,copy) NSString *accessToken;
//@property(nonatomic,copy) NSString *refreshToken;
//@property(nonatomic,copy) NSString *scope;
//@property(nonatomic,copy) NSString *expiresIn;
//@property(nonatomic,copy) NSString *nickName;
//@property(nonatomic,copy) NSString *headerUrl;
//
//@property(nonatomic,copy) NSString *userId;
//
//@property(nonatomic,copy) NSString *unionId;
//@property(nonatomic,copy) NSString *code;
//@property(nonatomic,copy) NSString *openId;
- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeBool:_isAuthorize forKey:@"isAuthorize"];
    
    [aCoder encodeObject:_expirationDate forKey:@"expirationDate"];
    
    [aCoder encodeObject:_accessToken forKey:@"accessToken"];
    [aCoder encodeObject:_refreshToken forKey:@"refreshToken"];
    [aCoder encodeObject:_scope forKey:@"scope"];
    [aCoder encodeObject:_expiresIn forKey:@"expiresIn"];
    [aCoder encodeObject:_nickName forKey:@"nickName"];
    [aCoder encodeObject:_headerUrl forKey:@"headerUrl"];
    
    [aCoder encodeObject:_userId forKey:@"userId"];
    
    [aCoder encodeObject:_unionId forKey:@"unionId"];
    [aCoder encodeObject:_code forKey:@"code"];
    [aCoder encodeObject:_openId forKey:@"openId"];
    

}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
//        _isAuthorize = [aDecoder decodeBoolForKey:@"isAuthorize"];
        
        _expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
        
        _accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
        _refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
        _scope = [aDecoder decodeObjectForKey:@"scope"];
        _expiresIn = [aDecoder decodeObjectForKey:@"expiresIn"];
        _nickName = [aDecoder decodeObjectForKey:@"nickName"];
        _headerUrl = [aDecoder decodeObjectForKey:@"headerUrl"];
        
        _userId = [aDecoder decodeObjectForKey:@"userId"];
        
        _unionId = [aDecoder decodeObjectForKey:@"unionId"];
        _code = [aDecoder decodeObjectForKey:@"code"];
        _openId = [aDecoder decodeObjectForKey:@"openId"];
        
    }
    return self;
}

- (BOOL)isAuthorize{
    if (_expirationDate ) {
        NSComparisonResult result = [[NSDate new]compare:_expirationDate];
        if (result == NSOrderedDescending) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}


- (void)clearInfo{
    _expirationDate = nil;
    
    _accessToken = @"";
    _refreshToken = @"";
    _scope = @"";
    _expiresIn = @"";
    _nickName = @"";
    _headerUrl = @"";
    
    _userId = @"";
    
    _unionId = @"";
    _code = @"";
    _openId = @"";

}

- (void)saveToPath:(NSString *)path{
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

+ (SCUserModel *)loadFromPath:(NSString *)path{
    SCUserModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (model == nil) {
        model = [SCUserModel new];
    }
    return model;
}


@end
