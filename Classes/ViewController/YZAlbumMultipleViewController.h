//
//  AlbumMultipleViewController.h
//  DoAlbum_SM
//
//  Created by yz on 15/4/29.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^SelectSucess)(NSMutableArray *selectImageArr);
typedef void (^CancelSelect) (NSError *error);

@interface YZAlbumMultipleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSMutableArray *assetsGroups;
@property (strong,nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong,nonatomic) UITableView *myTableView;
@property (assign,nonatomic) CGSize imgSize;
@property (strong,nonatomic) NSMutableArray *selectAssets;

@property (nonatomic, copy) SelectSucess selectSucessBlock;
@property (nonatomic, copy) CancelSelect cancelSelectBlock;
@property (nonatomic,assign) NSInteger num;

@end
