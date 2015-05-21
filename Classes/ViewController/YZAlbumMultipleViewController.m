//
//  AlbumMultipleViewController.m
//  DoAlbum_SM
//
//  Created by yz on 15/4/29.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#define MaxPic

#import "YZAlbumMultipleViewController.h"
#import "YZAlbumUIImageView.h"
#import "YZCheckBoxResource.h"
#import "NSData+DoBase64.h"

@interface YZAlbumMultipleViewController ()

@end

@implementation YZAlbumMultipleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"多选图片";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sureAction)];
    self.imgSize = CGSizeMake(75, 75);
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.myTableView = tableView;
    [self.view addSubview:self.myTableView];
    
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if(assetsGroup) {
            [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        NSMutableArray *cachearr = [[NSMutableArray  alloc] init];
        if(assetsGroup.numberOfAssets > 0) {
            [cachearr addObject:assetsGroup];
            ALAssetsGroup *assetsGroupAA = [cachearr objectAtIndex:0];
            [assetsGroupAA enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result) {
                    [self.assetsGroups addObject:result];
                    [self.myTableView reloadData];
                }
            }];
        }
    };
    
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        //NSLog(@"Error: %@", [error localizedDescription]);
    };
    
    // Enumerate Camera Roll
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Photo Stream
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Album
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Event
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupEvent usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Faces
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupFaces usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    

}
#pragma -mark -
#pragma -mark 懒加载
-(ALAssetsLibrary *)assetsLibrary
{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

-(NSMutableArray *)assetsGroups
{
    if (_assetsGroups == nil) {
        _assetsGroups = [[NSMutableArray alloc]init];
    }
    return _assetsGroups;
}

-(NSMutableArray *)selectAssets
{
    if (_selectAssets == nil) {
        _selectAssets = [[NSMutableArray alloc]init];
    }
    return _selectAssets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

#pragma -mark -
#pragma -mark UITableViewDelegate代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 0;
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imgSize.width;
    CGFloat margin = round((self.view.bounds.size.width - self.imgSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
    
    heightForRow = margin + self.imgSize.height;
    return heightForRow;
}
#pragma -mark -
#pragma -mark UITableViewDataSource代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imgSize.width;
    numberOfRowsInSection = self.assetsGroups.count / numberOfAssetsInRow;
    if((self.assetsGroups.count - numberOfRowsInSection * numberOfAssetsInRow) > 0) numberOfRowsInSection++;
    
    return numberOfRowsInSection;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idcell = @"albumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idcell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idcell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imgSize.width;
    CGFloat margin = round((self.view.bounds.size.width - self.imgSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
    
    NSInteger aaa = self.assetsGroups.count%numberOfAssetsInRow;
    
    NSInteger numberOfRowsInSection = 0;
    numberOfRowsInSection = self.assetsGroups.count / numberOfAssetsInRow;
    if((self.assetsGroups.count - numberOfRowsInSection * numberOfAssetsInRow) > 0) numberOfRowsInSection++;
    
    if (indexPath.row == (numberOfRowsInSection-1))
    {
        numberOfAssetsInRow = aaa;
    }
    
    for (int i=0; i<numberOfAssetsInRow; i++)
    {
        YZAlbumUIImageView *myImgView = [[YZAlbumUIImageView alloc] initWithFrame:CGRectMake(i*(self.imgSize.width+margin), margin, self.imgSize.width, self.imgSize.height)];
        myImgView.userInteractionEnabled = YES;
        [self addGesture:myImgView];
        ALAsset *asset  = [self.assetsGroups objectAtIndex:i+(indexPath.row*numberOfAssetsInRow)];
        myImgView.asset = asset;
        UIImage *myimg = [UIImage imageWithCGImage:asset.thumbnail];
        myImgView.image = myimg;
        [cell.contentView addSubview:myImgView];
        
        if ([self.selectAssets containsObject:asset])
        {
            UIImageView *cacheImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, myImgView.frame.size.width, myImgView.frame.size.height)];
            NSData *OKBytes = [NSData dataWithBase64EncodedString:[YZCheckBoxResource overlyBase64]];
            cacheImgView.image = [UIImage imageWithData:OKBytes];
            [myImgView addSubview:cacheImgView];
        }
        
    }
    return cell;
}

#pragma -mark -

-(void)addGesture:(UIView *)view
{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];//tap
    [view addGestureRecognizer:tap];
    tap.numberOfTapsRequired=1;//需要点击几次? required:需求
    tap.numberOfTouchesRequired=1;//几个触点啊？ touches:触点
}
-(void)tap:(UITapGestureRecognizer *)tap
{
    YZAlbumUIImageView *myImgView = (YZAlbumUIImageView*)tap.view;
    if ([self.selectAssets containsObject:myImgView.asset])
    {
        [self.selectAssets removeObject:myImgView.asset];
        [myImgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }else
    {
        
        if(self.selectAssets.count>= self.num)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相册"
                                                            message:[NSString stringWithFormat:@"最多只能选择%ld个图片",(long)self.num]
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        [self.selectAssets addObject:myImgView.asset];
        UIImageView *cacheImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, myImgView.frame.size.width, myImgView.frame.size.height)];
        
        NSData *OKBytes = [NSData dataWithBase64EncodedString:[YZCheckBoxResource overlyBase64]];
        cacheImgView.image = [UIImage imageWithData:OKBytes];
        [myImgView addSubview:cacheImgView];
    }
}



-(void)cancelAction
{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)sureAction
{
    
    if (self.selectAssets.count == 0) {
        self.cancelSelectBlock(nil);
    }else{
        self.selectSucessBlock(self.selectAssets);
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
