//
//  TZImagePickerController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "doYZImagePickerController.h"
#import "doYZPhotoPickerController.h"
#import "doYZPhotoPreviewController.h"
#import "doYZAssetModel.h"
#import "doYZAssetCell.h"
#import "UIView+Layout.h"
#import "doYZImageManager.h"

@interface doYZImagePickerController () {
    NSTimer *_timer;
    UILabel *_tipLable;
    BOOL _pushToPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLable;
}

@property (nonatomic, assign) doYZAlbumType albumType;

@end

@implementation doYZImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    // Default appearance, you can reset these after this method
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
        
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[doYZImagePickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[doYZImagePickerController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<TZImagePickerControllerDelegate>)delegate albumType:(doYZAlbumType)albumType {
    _albumType = albumType;
    doYZAlbumPickerController *albumPickerVc = [[doYZAlbumPickerController alloc] init];
    albumPickerVc.albumType = albumType;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        _allowPickingOriginalPhoto = YES;
        _allowPickingVideo = YES;
        
        if (![[doYZImageManager manager] authorizationStatusAuthorized]) {
            _tipLable = [[UILabel alloc] init];
            _tipLable.frame = CGRectMake(8, 0, self.view.tz_width - 16, 300);
            _tipLable.textAlignment = NSTextAlignmentCenter;
            _tipLable.numberOfLines = 0;
            _tipLable.font = [UIFont systemFontOfSize:16];
            _tipLable.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            _tipLable.text = [NSString stringWithFormat:@"请在%@的\"设置-隐私-照片\"选项中，\r允许%@访问你的手机相册。",[UIDevice currentDevice].model,appName];
            [self.view addSubview:_tipLable];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
        } else {
            [self pushToPhotoPickerVc];
        }
    }
    return self;
    
}

- (void)observeAuthrizationStatusChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[doYZImageManager manager] authorizationStatusAuthorized]) {
            [self pushToPhotoPickerVc];
            [_tipLable removeFromSuperview];
            [_timer invalidate];
            _timer = nil;
        }
    });
}

- (void)pushToPhotoPickerVc {
    _pushToPhotoPickerVc = YES;
    if (_pushToPhotoPickerVc) {
        doYZPhotoPickerController *photoPickerVc = [[doYZPhotoPickerController alloc] init];
        photoPickerVc.albumType = _albumType;
        [[doYZImageManager manager] getCameraRollAlbum:self.allowPickingVideo completion:^(doYZAlbumModel *model) {
            photoPickerVc.model = model;
            [self pushViewController:photoPickerVc animated:YES];
            _pushToPhotoPickerVc = NO;
        }];
    }
}

- (void)showAlertWithTitle:(NSString *)title {
    if (iOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
    }
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];

        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake((self.view.tz_width - 120) / 2, (self.view.tz_height - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLable = [[UILabel alloc] init];
        _HUDLable.frame = CGRectMake(0,40, 120, 50);
        _HUDLable.textAlignment = NSTextAlignmentCenter;
        _HUDLable.text = @"正在处理...";
        _HUDLable.font = [UIFont systemFontOfSize:15];
        _HUDLable.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLable];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
    // 去掉动画效果: 带动画的dismiss之后如果紧跟popToViewController,popToViewController会失效.
    [self dismissViewControllerAnimated:false completion:nil];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (iOS7Later) viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (_timer) { [_timer invalidate]; _timer = nil;}
    
    if (self.childViewControllers.count > 0) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 44, 44)];
        [backButton setImage:[UIImage imageNamed:@"do_Album.bundle/navi_back"] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [backButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    [super pushViewController:viewController animated:animated];
}

@end


@interface doYZAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
    NSMutableArray *_albumArr;
}

@end

static NSString *CellIdentifier = @"doYZAlbumCell";
@implementation doYZAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self configTableView];
    [self setupDeviceOrientatinChangeNofitify];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_albumArr) return;
    [self configTableView];
}

- (void)configTableView {
    doYZImagePickerController *imagePickerVc = (doYZImagePickerController *)self.navigationController;
    [[doYZImageManager manager] getAllAlbums:imagePickerVc.allowPickingVideo completion:^(NSArray<doYZAlbumModel *> *models) {
        _albumArr = [NSMutableArray array];
        for (doYZAlbumModel *albumModel in models) {
            if ([albumModel.result isKindOfClass:[PHFetchResult class]]) { // iOS 8 以后
                PHFetchResult *fetchResult = (PHFetchResult*)albumModel.result;
                doYZAlbumType type = [self getPHFetchResultTypeOf:fetchResult];
                albumModel.typeOfContainPHAsset = type;
                if (_albumType == doYZAlbumAll) { // 用户设置当前可混合选择
                    [_albumArr addObject:albumModel];
                }else if (_albumType == doYZAlbumVideo){ // 用户设置当前只能选择视频
                    if (type == doYZAlbumVideo || type == doYZAlbumAll) {
                        [_albumArr addObject:albumModel];
                    }
                    
                }else { // 用户设置当前只能选择相片
                    if (type == doYZAlbumPhoto || type == doYZAlbumAll) {
                        [_albumArr addObject:albumModel];
                    }
                }
            }
        }
        CGFloat top = 44;
        if (iOS7Later) top += 20;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, self.view.tz_width, self.view.tz_height - top) style:UITableViewStylePlain];
        _tableView.rowHeight = 70;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"do_Album" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:bundle];
            [_tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        [self.view addSubview:_tableView];
    }];
}

- (doYZAlbumType)getPHFetchResultTypeOf:(PHFetchResult*)fetchResult {
    NSInteger videoPHAssetCount = [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    NSInteger imagePHAssetCount = [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    if (videoPHAssetCount != 0 && imagePHAssetCount == 0) { // 纯video PHFetchResult
        return doYZAlbumVideo;
    }else if (imagePHAssetCount != 0 && videoPHAssetCount == 0) { // 纯image PHFetchResult
        return doYZAlbumPhoto;
    }
    return doYZAlbumAll; // 混合
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

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    doYZAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.albumType = _albumType;
    cell.model = _albumArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    doYZPhotoPickerController *photoPickerVc = [[doYZPhotoPickerController alloc] init];
    photoPickerVc.albumType = _albumType;
    photoPickerVc.model = _albumArr[indexPath.row];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

- (void)resetView{
    [_tableView removeFromSuperview];
    _tableView = nil;
    [self configTableView];
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
