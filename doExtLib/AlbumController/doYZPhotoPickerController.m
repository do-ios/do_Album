//
//  TZPhotoPickerController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "doYZPhotoPickerController.h"
#import "doYZImagePickerController.h"
#import "doYZPhotoPreviewController.h"
#import "doYZAssetCell.h"
#import "doYZAssetModel.h"
#import "UIView+Layout.h"
#import "doYZImageManager.h"
#import "doYZVideoPlayerController.h"

@interface doYZPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate> {
    UICollectionView *_collectionView;
    NSMutableArray *_photoArr;
    
    UIButton *_previewButton;
    UIButton *_okButton;
    UIImageView *_numberImageView;
    UILabel *_numberLable;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLable;
    
    BOOL _isSelectOriginalPhoto;
    BOOL _shouldScrollToBottom;
}
@property (nonatomic, strong) NSMutableArray *selectedPhotoArr;
@property CGRect previousPreheatRect;
@property (nonatomic, strong) UIView *bottomToolBar;
@end

static CGSize AssetGridThumbnailSize;
static NSString *cellID = @"doYZAssetCell";
@implementation doYZPhotoPickerController

- (NSMutableArray *)selectedPhotoArr {
    if (_selectedPhotoArr == nil) _selectedPhotoArr = [NSMutableArray array];
    return _selectedPhotoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    doYZImagePickerController *imagePickerVc = (doYZImagePickerController *)self.navigationController;
//    [[doYZImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:imagePickerVc.allowPickingVideo completion:^(NSArray<doYZAssetModel *> *models) {
//        _photoArr = [NSMutableArray arrayWithArray:models];
//        [self configCollectionView];
//        [self configBottomToolBar];
//    }];
    [[doYZImageManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:imagePickerVc.allowPickingVideo completion:^(NSArray<doYZAssetModel *> *models) {
        _photoArr = [NSMutableArray arrayWithArray:models];
        [self configCollectionView];
        [self configBottomToolBar];
    } albumType:_albumType];
    [self resetCachedAssets];
    [self setupDeviceOrientatinChangeNofitify];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 4;
    CGFloat itemWH = (self.view.tz_width - 2 * margin - 4) / 4 - margin;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    CGFloat top = margin + 44;
    if (iOS7Later) top += 20;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(margin, top, self.view.tz_width - 2 * margin, self.view.tz_height - 50 - top) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceHorizontal = NO;
    if (iOS7Later) _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 2);
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    _collectionView.contentSize = CGSizeMake(self.view.tz_width, ((_model.count + 3) / 4) * self.view.tz_width);
    [self.view addSubview:_collectionView];
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"do_Album" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        UINib *nib = [UINib nibWithNibName:cellID bundle:bundle];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:cellID];
        nibsRegistered = YES;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_shouldScrollToBottom && _photoArr.count > 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(_photoArr.count - 1) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        _shouldScrollToBottom = NO;
    }
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS8Later) {
        // [self updateCachedAssets];
    }}

- (void)configBottomToolBar {
    _bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.tz_height - 50, self.view.tz_width, 50)];
    CGFloat rgb = 253 / 255.0;
    _bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewButton.frame = CGRectMake(10, 3, 44, 44);
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_previewButton setTitle:@"预览" forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = NO;
    
    doYZImagePickerController *imagePickerVc = (doYZImagePickerController *)self.navigationController;
    if (imagePickerVc.allowPickingOriginalPhoto) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(50, self.view.tz_height - 50, 130, 50);
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        _originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:@"原图" forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamed:@"do_Album.bundle/photo_original_def"] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamed:@"do_Album.bundle/photo_original_sel"] forState:UIControlStateSelected];
        _originalPhotoButton.enabled = _selectedPhotoArr.count > 0;
        
        _originalPhotoLable = [[UILabel alloc] init];
        _originalPhotoLable.frame = CGRectMake(70, 0, 60, 50);
        _originalPhotoLable.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLable.font = [UIFont systemFontOfSize:16];
        _originalPhotoLable.textColor = [UIColor blackColor];
        if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    }
    
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(self.view.tz_width - 44 - 12, 3, 44, 44);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:@"确定" forState:UIControlStateNormal];
    [_okButton setTitle:@"确定" forState:UIControlStateDisabled];
    [_okButton setTitleColor:imagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_okButton setTitleColor:imagePickerVc.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
    _okButton.enabled = NO;
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"do_Album.bundle/photo_number_icon"]];
    _numberImageView.frame = CGRectMake(self.view.tz_width - 56 - 24, 12, 26, 26);
    _numberImageView.hidden = _selectedPhotoArr.count <= 0;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLable = [[UILabel alloc] init];
    _numberLable.frame = _numberImageView.frame;
    _numberLable.font = [UIFont systemFontOfSize:16];
    _numberLable.textColor = [UIColor whiteColor];
    _numberLable.textAlignment = NSTextAlignmentCenter;
    _numberLable.text = [NSString stringWithFormat:@"%zd",_selectedPhotoArr.count];
    _numberLable.hidden = _selectedPhotoArr.count <= 0;
    _numberLable.backgroundColor = [UIColor clearColor];
    
    UIView *divide = [[UIView alloc] init];
    CGFloat rgb2 = 222 / 255.0;
    divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    divide.frame = CGRectMake(0, 0, self.view.tz_width, 1);

    [_bottomToolBar addSubview:divide];
    [_bottomToolBar addSubview:_previewButton];
    [_bottomToolBar addSubview:_okButton];
    [_bottomToolBar addSubview:_numberImageView];
    [_bottomToolBar addSubview:_numberLable];
    [self.view addSubview:_bottomToolBar];
    [self.view addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLable];
}

#pragma mark - Click Event

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    doYZImagePickerController *imagePickerVc = (doYZImagePickerController *)self.navigationController;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [imagePickerVc.pickerDelegate imagePickerControllerDidCancel:imagePickerVc];
    }
    if (imagePickerVc.imagePickerControllerDidCancelHandle) {
        imagePickerVc.imagePickerControllerDidCancelHandle();
    }
}

- (void)previewButtonClick {
    doYZPhotoPreviewController *photoPreviewVc = [[doYZPhotoPreviewController alloc] init];
    photoPreviewVc.photoArr = [NSArray arrayWithArray:self.selectedPhotoArr];
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)okButtonClick {
    doYZImagePickerController *imagePickerVc = (doYZImagePickerController *)self.navigationController;
    [imagePickerVc showProgressHUD];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < _selectedPhotoArr.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
    
    for (NSInteger i = 0; i < _selectedPhotoArr.count; i++) {
        doYZAssetModel *model = _selectedPhotoArr[i];
        [[doYZImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            
            if (isDegraded) return;
            if (photo) [photos replaceObjectAtIndex:i withObject:photo];
            if (info) [infoArr replaceObjectAtIndex:i withObject:info];
//            if (_isSelectOriginalPhoto)
            [assets replaceObjectAtIndex:i withObject:model.asset];

            for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
            
            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:)]) {
                [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingPhotos:photos sourceAssets:assets];
            }
            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:infos:)]) {
                [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingPhotos:photos sourceAssets:assets infos:infoArr];
            }
//            if (imagePickerVc.didFinishPickingPhotosHandle) {
//                imagePickerVc.didFinishPickingPhotosHandle(photos,assets);
//            }
//            if (imagePickerVc.didFinishPickingPhotosWithInfosHandle) {
//                imagePickerVc.didFinishPickingPhotosWithInfosHandle(photos,assets,infoArr);
//            }

        }];
    }
    [imagePickerVc hideProgressHUD];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    doYZAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    doYZAssetModel *model = _photoArr[indexPath.row];
    cell.model = model;
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        // 1. cancel select / 取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            [weakSelf.selectedPhotoArr removeObject:model];
            [weakSelf refreshBottomToolBarStatus];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            doYZImagePickerController *imagePickerVc = (doYZImagePickerController *)weakSelf.navigationController;
            if (weakSelf.selectedPhotoArr.count < imagePickerVc.maxImagesCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [weakSelf.selectedPhotoArr addObject:model];
                [weakSelf refreshBottomToolBarStatus];
            } else {
                [imagePickerVc showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",imagePickerVc.maxImagesCount]];
            }
        }
         [UIView showOscillatoryAnimationWithLayer:weakLayer type:TZOscillatoryAnimationToSmaller];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    doYZAssetModel *model = _photoArr[indexPath.row];
    if (model.type == TZAssetModelMediaTypeVideo) {
        if (_selectedPhotoArr.count > 0) {
            doYZImagePickerController *imagePickerVc = (doYZImagePickerController *)self.navigationController;
            [imagePickerVc showAlertWithTitle:@"选择照片时不能选择视频"];
        } else {
            doYZVideoPlayerController *videoPlayerVc = [[doYZVideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else {
        doYZPhotoPreviewController *photoPreviewVc = [[doYZPhotoPreviewController alloc] init];
        photoPreviewVc.photoArr = _photoArr;
        photoPreviewVc.currentIndex = indexPath.row;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (iOS8Later) {
        // [self updateCachedAssets];
    }
}

#pragma mark - Private Method

- (void)refreshBottomToolBarStatus {
    _previewButton.enabled = self.selectedPhotoArr.count > 0;
    _okButton.enabled = self.selectedPhotoArr.count > 0;
    
    _numberImageView.hidden = _selectedPhotoArr.count <= 0;
    _numberLable.hidden = _selectedPhotoArr.count <= 0;
    _numberLable.text = [NSString stringWithFormat:@"%zd",_selectedPhotoArr.count];
    
    _originalPhotoButton.enabled = _selectedPhotoArr.count > 0;
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLable.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

- (void)pushPhotoPrevireViewController:(doYZPhotoPreviewController *)photoPreviewVc {
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    photoPreviewVc.selectedPhotoArr = self.selectedPhotoArr;
    photoPreviewVc.returnNewSelectedPhotoArrBlock = ^(NSMutableArray *newSelectedPhotoArr,BOOL isSelectOriginalPhoto) {
        _selectedPhotoArr = newSelectedPhotoArr;
        _isSelectOriginalPhoto = isSelectOriginalPhoto;
        [_collectionView reloadData];
        [self refreshBottomToolBarStatus];
    };
    photoPreviewVc.okButtonClickBlock = ^(NSMutableArray *newSelectedPhotoArr,BOOL isSelectOriginalPhoto){
        _selectedPhotoArr = newSelectedPhotoArr;
        _isSelectOriginalPhoto = isSelectOriginalPhoto;
        [self okButtonClick];
    };
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)getSelectedPhotoBytes {
    [[doYZImageManager manager] getPhotosBytesWithArray:_selectedPhotoArr completion:^(NSString *totalBytes) {
        _originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [[doYZImageManager manager].cachingImageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[doYZImageManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [[doYZImageManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        doYZAssetModel *model = _photoArr[indexPath.item];
        [assets addObject:model.asset];
    }
    
    return assets;
}

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

#pragma mark - 设备旋转处理

- (void)setupDeviceOrientatinChangeNofitify{
    // 开始生成 设备旋转 通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // 监听设备旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

- (void)resetView {
    [_collectionView removeFromSuperview];
    _collectionView = nil;
    [self configCollectionView];
    // 滚到底部
    CGPoint bottomOffset = CGPointMake(0, _collectionView.contentSize.height - _collectionView.bounds.size.height);
    [_collectionView setContentOffset:bottomOffset animated:NO];
    
    [_previewButton removeFromSuperview];
    _previewButton = nil;
    [_okButton removeFromSuperview];
    _okButton = nil;
    [_numberImageView removeFromSuperview];
    _numberImageView = nil;
    [_bottomToolBar removeFromSuperview];
    _bottomToolBar = nil;
    [_originalPhotoLable removeFromSuperview];
    _originalPhotoLable = nil;
    [_originalPhotoButton removeFromSuperview];
    _originalPhotoButton = nil;
    
    [self configBottomToolBar];
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    // 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    // 取得当前Device的方向，Device的方向类型为Integer ，必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            [self resetView];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            [self resetView];
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            [self resetView];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
    
}

- (void)dealloc {
    // 销毁 设备旋转 通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil
     ];
    // 结束 设备旋转通知
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
}

@end
