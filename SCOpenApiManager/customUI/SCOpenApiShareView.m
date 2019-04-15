//
//  SCOpenApiShareView.m
//  CaiJie
//
//  Created by SuoChenhe on 15/12/23.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//
static NSString *cellIdentifier = @"SCOpenApiShareViewCell";

#import "SCOpenApiShareView.h"
#import "SCOpenApiManager.h"
@implementation SCShareCellModel
@end


@interface SCOpenApiShareView ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,weak) UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *dataSource;
@end

static CGFloat itemsPerRow = 4.f;
static CGFloat padding = 1.f;
static CGFloat itemW ;
static CGFloat itemH ;

@implementation SCOpenApiShareView

+ (SCOpenApiShareView *)showInView:(UIView *)view delegate:(id<SCOpenApiShareViewDelegate>)delegate{
    SCOpenApiShareView *shareView = [[SCOpenApiShareView alloc]initWithFrame:view.bounds];
    shareView.delegate = delegate;
    [view addSubview:shareView];
    return shareView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.alpha = 0;
        [self addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchDown];
        
        
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        itemW = (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - padding * (itemsPerRow - 1))/itemsPerRow;
        CGFloat WHScale = (itemsPerRow == 5) ? 1.2f : 1.f;
        itemH = itemW * WHScale;
        
        flowLayout.minimumLineSpacing = 1.f;
        flowLayout.minimumInteritemSpacing = 1.f;
        flowLayout.itemSize = CGSizeMake(itemW, itemH);
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1];
        [self addSubview:collectionView];
        _collectionView = collectionView;
        
        [self loadDataSource];
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    [_collectionView reloadData];
    
    CGFloat collectionViewW = _collectionView.bounds.size.width;
    if ( collectionViewW!= self.bounds.size.width ) {
        CGFloat rowNum = ceilf(_dataSource.count / itemsPerRow);
        CGFloat collectionViewH = rowNum * itemH + (rowNum - 1) * padding;
        
        CGRect frame = _collectionView.frame;
        frame.size.width = self.bounds.size.width;
        frame.size.height = collectionViewH;
        frame.origin.x = 0;
        frame.origin.y = self.bounds.size.height;
        _collectionView.frame = frame;
        
        frame.origin.y = self.bounds.size.height - frame.size.height;
        
        if (collectionViewW == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.f;
                _collectionView.frame = frame;
            }];
            
        }else{
            _collectionView.frame = frame;
        }
    }
    
}


- (void)loadDataSource{
//    @"qqIcon"
//    @"qZone"
//    @"sinaIcon"
//    @"wechatIcon"
//    @"wechatTimeLine"
    NSMutableArray *titleArray = [NSMutableArray arrayWithObject:@"新浪微博"];
    NSMutableArray *iconArray = [NSMutableArray arrayWithObject:@"sinaIcon"];
    NSMutableArray *platformArray = [NSMutableArray arrayWithObject:@(SCOpenPlatformTypeSina)];
    if ([SCOpenApiManager isQQInstalled]) {
//        [titleArray addObjectsFromArray:@[@"QQ",@"QQ空间"]];
//        [iconArray addObjectsFromArray:@[@"qqIcon",@"qZone"]];
//        [platformArray addObjectsFromArray:@[@(SCOpenPlatformTypeQQ),@(SCOpenPlatformTypeQzone)]];
        [titleArray addObjectsFromArray:@[@"QQ空间"]];
        [iconArray addObjectsFromArray:@[@"qZone"]];
        [platformArray addObjectsFromArray:@[@(SCOpenPlatformTypeQzone)]];
    }
    if ([SCOpenApiManager isWeChatInstalled]) {
        [titleArray addObjectsFromArray:@[@"微信",@"朋友圈"]];
        [iconArray addObjectsFromArray:@[@"wechatIcon",@"wechatTimeLine"]];
        [platformArray addObjectsFromArray:@[@(SCOpenPlatformTypeWeChat),@(SCOpenPlatformTypeWeChatCirle)]];
    }
    NSMutableArray *temp = [NSMutableArray array];
    for (NSInteger i = 0; i < titleArray.count; i ++) {
        SCShareCellModel *model = [SCShareCellModel new];
        model.title = titleArray[i];
        model.icon = iconArray[i];
        model.platformType = (SCOpenPlatformType)[platformArray[i] integerValue];
        [temp addObject:model];
    }
    _dataSource = [temp copy];
    
}

#pragma mark - Action
- (void)tapAction{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.f;
        CGRect frame = _collectionView.frame;
        frame.origin.y = self.bounds.size.height;
        _collectionView.frame = frame;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell.contentView.subviews.count == 0) {
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.91 alpha:0.8];
        
        CGFloat imageViewH = (itemsPerRow == 5) ? itemW * 0.6 : itemW * 0.4;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, itemW * 0.1, itemW, imageViewH)];
        imageView.tag = 1893951;
        imageView.userInteractionEnabled = YES;
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.contentMode = UIViewContentModeCenter;
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, CGRectGetMaxY(imageView.frame), itemW, itemW * 0.5)];
        label.tag = 1893952;
        label.textAlignment = NSTextAlignmentCenter;
        CGFloat fontSize = 12.f * [UIScreen mainScreen].bounds.size.width / 320.f;
        label.font = [UIFont systemFontOfSize:fontSize];
        [cell.contentView addSubview:label];
        
        UIView *sepLine1 = [[UIView alloc]initWithFrame:CGRectMake(itemW, 0.f, padding, itemH + padding)];
        sepLine1.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        [cell.contentView addSubview:sepLine1];
        UIView *sepLine2 = [[UIView alloc]initWithFrame:CGRectMake(0.f, itemH, itemW, padding)];
        sepLine2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        [cell.contentView addSubview:sepLine2];
    }
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1893951];
    UILabel *label = (UILabel *)[cell viewWithTag:1893952];
    
    SCShareCellModel *model = _dataSource[indexPath.row];
    imageView.image = [UIImage imageNamed:model.icon];
    label.text = model.title;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SCShareCellModel *model = _dataSource[indexPath.row];
    if (_delegate == nil) {
        [SCOpenApiManager shareToPlatform:model.platformType];
    }else if ([_delegate respondsToSelector:@selector(openApiShareViewDidSelectedWithModel:)]) {
        [_delegate openApiShareViewDidSelectedWithModel:model];
    }
}

@end
