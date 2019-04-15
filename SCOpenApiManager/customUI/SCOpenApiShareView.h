//
//  SCOpenApiShareView.h
//  CaiJie
//
//  Created by SuoChenhe on 15/12/23.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SCOpenApiManager.h"
@interface SCShareCellModel : NSObject
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *icon;
@property (nonatomic,assign)SCOpenPlatformType platformType;
@end

@protocol SCOpenApiShareViewDelegate <NSObject>

- (void)openApiShareViewDidSelectedWithModel:(SCShareCellModel *)model;

@end

@interface SCOpenApiShareView : UIButton
@property(nonatomic,weak)id<SCOpenApiShareViewDelegate> delegate;

+ (SCOpenApiShareView *)showInView:(UIView *)view delegate:(id<SCOpenApiShareViewDelegate>) delegate;

@end
