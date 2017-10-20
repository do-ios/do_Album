//
//  do_Album_SM.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Album_SM.h"
#import <UIKit/UIKit.h>

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doIPage.h"
#import "doSourceFile.h"
#import "doUIModuleHelper.h"
#import "doIPage.h"
#import "doIScriptEngine.h"
#import "doDefines.h"
#import "doIApp.h"
#import "doIDataFS.h"
#import "doIOHelper.h"
#import "doJsonHelper.h"
#import "doYZImagePickerController.h"
#import "doAlbumCropViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/ALAsset.h>
#import "doServiceContainer.h"
#import "doLogEngine.h"
#import "doYZVideoPlayerController.h"
@interface do_Album_SM()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate,doAlbumCropViewControllerDelegate>

@property(nonatomic,copy) NSString *myCallbackName;
@property(nonatomic,weak) id<doIScriptEngine> myScritEngine;
@property (nonatomic, strong ) UIImage *tempImage;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) NSInteger imageQuality;
@property (nonatomic, assign) NSInteger imageWidth;
@property (nonatomic, assign) NSInteger imageHeight;
@property (nonatomic, assign) NSInteger imageNum;
@property (nonatomic, assign) BOOL isCut;
@property (nonatomic, strong) NSTimer *timerToFireSelectResult;
@property (nonatomic, assign) int countForFireSelectResult;
@property (nonatomic, strong) NSMutableArray<NSString *> *selectedPhotoPathsArray;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *interceptTouchView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *exportLoadingLabel;
@end

@implementation do_Album_SM
- (void)OnInit {
    [super OnInit];
    _countForFireSelectResult = 0;
    _timerToFireSelectResult = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fireSelectResult) userInfo:nil repeats:YES];
    [_timerToFireSelectResult setFireDate:[NSDate distantFuture]];
    _selectedPhotoPathsArray = [NSMutableArray array];
}
- (void)Dispose {
    [super Dispose];
    _timerToFireSelectResult = nil;
    _countForFireSelectResult = 0;
    _selectedPhotoPathsArray = nil;
}

- (void)fireSelectResult {
    if (_countForFireSelectResult == _selectedPhotoPathsArray.count) {
        doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
        [_invokeResult SetResultArray:_selectedPhotoPathsArray];
        [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
        [_timerToFireSelectResult setFireDate:[NSDate distantFuture]];
        _countForFireSelectResult = 0;
    }
}

#pragma mark - lazy

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.frame = CGRectMake(0, 40, 150, 50);
        return _indicatorView;
    }
    return _indicatorView;
}

- (UILabel *)exportLoadingLabel {
    if (_exportLoadingLabel == nil) {
        _exportLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 150, 50)];
        _exportLoadingLabel.textColor = [UIColor whiteColor];
        _exportLoadingLabel.textAlignment = NSTextAlignmentCenter;
        _exportLoadingLabel.font = [UIFont systemFontOfSize:13];
        _exportLoadingLabel.text = @"系统视频保存本地中...";
        return _exportLoadingLabel;
    }
    return _exportLoadingLabel;
}


- (UIView *)interceptTouchView {
    if (_interceptTouchView == nil) {
        _interceptTouchView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        [_interceptTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing)]];
        return _interceptTouchView;
    }
    return  _interceptTouchView;
}

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.layer.cornerRadius = 30.0f;
        _coverView.layer.masksToBounds = true;
        float x = 0.0f;
        float y = 0.0f;
        float W = 150.0f;
        float H = 150.0f;
        x = ([UIScreen mainScreen].bounds.size.width - W) / 2;
        y = ([UIScreen mainScreen].bounds.size.height - H) / 2;
        _coverView.frame = CGRectMake(x, y, W, H);
        
        return _coverView;
    }
    return _coverView;
}

#pragma mark -
#pragma mark - 同步异步方法的实现
/*
 1.参数节点
 doJsonNode *_dictParas = [parms objectAtIndex:0];
 a.在节点中，获取对应的参数
 NSString *title = [_dictParas GetOneText:@"title" :@"" ];
 说明：第一个参数为对象名，第二为默认值
 
 2.脚本运行时的引擎
 id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
 3.同步回调对象(有回调需要添加如下代码)
 doInvokeResult *_invokeResult = [parms objectAtIndex:2];
 回调信息
 如：（回调一个字符串信息）
 [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
 3.获取回调函数名(异步方法都有回调)
 NSString *_callbackName = [parms objectAtIndex:2];
 在合适的地方进行下面的代码，完成回调
 新建一个回调对象
 doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
 填入对应的信息
 如：（回调一个字符串）
 [_invokeResult SetResultText: @"异步方法完成"];
 [_scritEngine Callback:_callbackName :_invokeResult];
 */
//同步
//异步
- (void)save:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *_path = [doJsonHelper GetOneText:_dictParas :@"path" :@""];
    NSInteger imageWidth = [doJsonHelper GetOneInteger:_dictParas :@"width" :-1];
    NSInteger imageHeight = [doJsonHelper GetOneInteger:_dictParas :@"height" :-1];
    NSInteger imageQuality = [doJsonHelper GetOneInteger:_dictParas :@"quality" :100];
    NSString *_callbackName = [parms objectAtIndex:2];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init:self.UniqueKey];
    if (_path ==nil || _path.length <=0) { //失败
        [_invokeResult SetResultBoolean:false];
    }
    else
    {
        NSString * imagePath = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :_path];
        if(![doIOHelper ExistFile:imagePath]){
            [_invokeResult SetResultBoolean:false];
            [_scritEngine Callback:_callbackName :_invokeResult];//返回结果
            return;
        }
        
        if (imagePath ==nil || imagePath.length <= 0) {//失败
            [_invokeResult SetResultBoolean:false];
            [_scritEngine Callback:_callbackName :_invokeResult];//返回结果
            return;
        }
        UIImage *imageTemp = [UIImage imageWithContentsOfFile:imagePath];
        if (imagePath == nil) {//失败
            [_invokeResult SetResultBoolean:false];
            [_scritEngine Callback:_callbackName :_invokeResult];//返回结果
            return;
        }
        if (imageWidth >=0 && imageHeight >= 0) {//设置图片大小
            imageTemp = [doUIModuleHelper imageWithImageSimple:imageTemp scaledToSize:CGSizeMake(imageWidth, imageHeight)];
        }
        if(imageQuality > 100)imageQuality  = 100;
        if(imageQuality<0)imageQuality = 1;
        NSData *imageData = UIImageJPEGRepresentation(imageTemp, imageQuality/100);
        imageTemp = [UIImage imageWithData:imageData];
        UIImageWriteToSavedPhotosAlbum(imageTemp, nil, nil, nil);//保存图片到相册
        [_invokeResult SetResultBoolean:true];
    }
    [_scritEngine Callback:_callbackName :_invokeResult];//返回结果
}

- (void)select:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    self.myScritEngine = [parms objectAtIndex:1];
    self.myCallbackName = [parms objectAtIndex:2];
    //自己的代码实现
    _imageNum = [doJsonHelper GetOneInteger:_dictParas :@"maxCount" :9];
    _imageWidth = [doJsonHelper GetOneInteger:_dictParas :@"width" :-1];
    _imageHeight = [doJsonHelper GetOneInteger:_dictParas :@"height" :-1];
    _imageQuality = [doJsonHelper GetOneInteger:_dictParas :@"quality" :100];
    _isCut = [doJsonHelper GetOneBoolean:_dictParas :@"iscut" :NO];
    NSInteger type = [doJsonHelper GetOneInteger:_dictParas :@"type" :0];
    doYZAlbumType albumType = doYZAlbumAll;
    switch (type) {
        case 0:
            albumType = doYZAlbumAll;
            break;
        case 1:
            albumType = doYZAlbumPhoto;
            break;
        case 2:
            albumType = doYZAlbumVideo;
            break;
        default:
            break;
    }
    id<doIPage> curPage = [self.myScritEngine CurrentPage];
    
    UIViewController *curVc = (UIViewController *)curPage.PageView;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        doYZImagePickerController *imagePickerVc = [[doYZImagePickerController alloc] initWithMaxImagesCount:_imageNum delegate:self albumType:albumType];
        imagePickerVc.allowPickingOriginalPhoto = NO;
        if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) { // iOS8 一下的不予支持视频选择
            imagePickerVc.allowPickingVideo = NO;
        }else {
            imagePickerVc.allowPickingVideo = YES;
        }
        [curVc presentViewController:imagePickerVc animated:YES completion:nil];
    });
}

- (void) openDoYZCropViewController:(id)asset
{
    doAlbumCropViewController *vc = [[doAlbumCropViewController alloc]init];
    vc.asset = asset;
    vc.image = self.tempImage;
    vc.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    id<doIPage> pageModel = _myScritEngine.CurrentPage;
    UIViewController * currentVC = (UIViewController *)pageModel.PageView;
    // 更改UI的操作，必须回到主线程
//    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
//    dispatch_after(when, dispatch_get_main_queue(), ^{
//            [currentVC presentViewController:navigationController animated:YES completion:nil];
//    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentVC presentViewController:navigationController animated:YES completion:nil];
    });
}
#pragma mark - 私有方法
- (void)saveImageToLocalWithAsset:(doAlbumCropViewController*)controller
{
    NSMutableArray *urlArr = [[NSMutableArray alloc]init];
    NSString *_fileFullName = [self.myScritEngine CurrentApp].DataFS.RootPath;
    
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[doUIModuleHelper stringWithUUID]];
    NSString *filePath = [NSString stringWithFormat:@"%@/temp/do_Album/%@",_fileFullName,fileName];
    
    self.tempImage = [doUIModuleHelper imageWithImageSimple:self.tempImage scaledToSize:self.imageSize];
    CGSize imageSize = self.imageSize;
    NSData *imageData = UIImageJPEGRepresentation(self.tempImage, self.imageQuality / 100.0);
    self.tempImage = [UIImage imageWithData:imageData];
    NSString *path = [NSString stringWithFormat:@"%@/temp/do_Album",_fileFullName];
    
    if ([controller.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *originalAsset = (PHAsset*)controller.asset;
        // get extra info
        PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
        //        options.networkAccessAllowed = YES; //download asset metadata from iCloud if needed, not supported now
//        __weak typeof(self) weakSelf = self;
        [originalAsset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
            NSMutableDictionary *TIFFDICTIONARY = [fullImage.properties[(NSString*)kCGImagePropertyTIFFDictionary] mutableCopy];
            NSMutableDictionary *EXIFDICTIONARY = [fullImage.properties[(NSString*)kCGImagePropertyExifDictionary] mutableCopy];
            NSMutableDictionary *metadataAsMutable = [NSMutableDictionary dictionary];
            if (EXIFDICTIONARY){
                if ([EXIFDICTIONARY objectForKey:@"PixelXDimension"]) {
                    EXIFDICTIONARY[@"PixelXDimension"] = [NSNumber numberWithFloat:imageSize.width];
                }
                if ([EXIFDICTIONARY objectForKey:@"PixelYDimension"]) {
                    EXIFDICTIONARY[@"PixelYDimension"] = [NSNumber numberWithFloat:imageSize.height];

                }
                [metadataAsMutable setObject:EXIFDICTIONARY forKey:(NSString *)kCGImagePropertyExifDictionary];
            }
            if (TIFFDICTIONARY)[metadataAsMutable setObject:TIFFDICTIONARY forKey:(NSString *)kCGImagePropertyTIFFDictionary];
            
//            id width = [NSString stringWithFormat:@"%@",[self checkEmpty:[exif objectForKey:@"PixelXDimension"]]];
//            id height = [NSString stringWithFormat:@"%@",[self checkEmpty:[exif objectForKey:@"PixelYDimension"]]];
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
            
            CFStringRef UTI = CGImageSourceGetType(imageSource); //this is the type of image (e.g., public.jpeg)
            
            //this will be the data CGImageDestinationRef will write into
            NSMutableData *dest_data = [NSMutableData data];
            
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
            
            if(!destination) {
                NSLog(@"***Could not create image destination ***");
            }
            
            //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
            CGImageDestinationAddImageFromSource(destination,imageSource,0, (CFDictionaryRef) metadataAsMutable);
            //tell the destination to write the image data and metadata into our data object.
            //It will return false if something goes wrong
            BOOL success = NO;
            success = CGImageDestinationFinalize(destination);
            
            if(!success) {
                NSLog(@"***Could not create data from image destination ***");
            }
            //            image = [UIImage imageWithData:imageData];
            
            if(![doIOHelper ExistDirectory:path])
            [doIOHelper CreateDirectory:path];
            [doIOHelper WriteAllBytes:filePath :dest_data];
            
            //cleanup
            CFRelease(destination);
            CFRelease(imageSource);
            
            [urlArr addObject:[NSString stringWithFormat:@"data://temp/do_Album/%@",fileName]];
            doInvokeResult *_invokeResult = [[doInvokeResult alloc]init];
            [_invokeResult SetResultArray:urlArr];
            [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
            dispatch_async(dispatch_get_main_queue(), ^{
                [controller dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }else {
        if(![doIOHelper ExistDirectory:path])
        [doIOHelper CreateDirectory:path];
        [doIOHelper WriteAllBytes:filePath :imageData];
        [urlArr addObject:[NSString stringWithFormat:@"data://temp/do_Album/%@",fileName]];
        doInvokeResult *_invokeResult = [[doInvokeResult alloc]init];
        [_invokeResult SetResultArray:urlArr];
        [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }

}

- (void)doNothing {
    NSLog(@"do nothing");
}

#pragma mark - doAlbumCropViewControllerDelegate方法

-(void)cropViewController:(doAlbumCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    self.tempImage = croppedImage;
    [self saveImageToLocalWithAsset:controller];
//    [controller dismissViewControllerAnimated:NO completion:nil];
}
- (void)cropViewControllerDidCancel:(doAlbumCropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)imagePickerControllerDidCancel:(doYZImagePickerController *)picker {
    
}

/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(doYZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSString *_fileFullName = [self.myScritEngine CurrentApp].DataFS.RootPath;
    NSMutableArray *urlArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < photos.count ; i ++) {
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[doUIModuleHelper stringWithUUID]];
        NSString *filePath = [NSString stringWithFormat:@"%@/temp/do_Album/%@",_fileFullName,fileName];
        __block UIImage *image = [photos objectAtIndex:i];
        CGSize size = CGSizeMake(_imageWidth, _imageHeight);
        CGFloat hwRatio = image.size.height/image.size.width;
        CGFloat whRatio = image.size.width/image.size.height;
        if (-1 == _imageHeight && -1 == _imageWidth) {//保持原始比例
            size = CGSizeMake(image.size.width, image.size.height);
        }
        else
        {
            if(-1 == _imageWidth)
            {
                size = CGSizeMake(_imageHeight*whRatio, _imageHeight);
            }
            if(-1 == _imageHeight)
            {
                size = CGSizeMake(_imageWidth, _imageWidth*hwRatio);
            }
        }
        if (_imageNum == 1 && _isCut) {
            self.tempImage = image;
            self.imageSize = size;
            self.imageQuality = _imageQuality;
            [self openDoYZCropViewController:assets[i]];
            return;
        }
        
        // get extra info
        PHAsset *originalAsset = assets[i];
        PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
        //        options.networkAccessAllowed = YES; //download asset metadata from iCloud if needed, not supported now
        __weak typeof(self) weakSelf = self;
        [originalAsset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
            NSDictionary *TIFFDICTIONARY = fullImage.properties[(NSString*)kCGImagePropertyTIFFDictionary];
            NSDictionary *EXIFDICTIONARY = fullImage.properties[(NSString*)kCGImagePropertyExifDictionary];
            NSMutableDictionary *metadataAsMutable = [NSMutableDictionary dictionary];
            if (EXIFDICTIONARY)[metadataAsMutable setObject:EXIFDICTIONARY forKey:(NSString *)kCGImagePropertyExifDictionary];
            if (TIFFDICTIONARY)[metadataAsMutable setObject:TIFFDICTIONARY forKey:(NSString *)kCGImagePropertyTIFFDictionary];
            
            image = [doUIModuleHelper imageWithImageSimple:image scaledToSize:size];
            NSData *imageData = UIImageJPEGRepresentation(image, _imageQuality / 100.0);
            
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
            
            CFStringRef UTI = CGImageSourceGetType(imageSource); //this is the type of image (e.g., public.jpeg)
            
            //this will be the data CGImageDestinationRef will write into
            NSMutableData *dest_data = [NSMutableData data];
            
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
            
            if(!destination) {
                NSLog(@"***Could not create image destination ***");
            }
            
            //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
            CGImageDestinationAddImageFromSource(destination,imageSource,0, (CFDictionaryRef) metadataAsMutable);
            //tell the destination to write the image data and metadata into our data object.
            //It will return false if something goes wrong
            BOOL success = NO;
            success = CGImageDestinationFinalize(destination);
            
            if(!success) {
                NSLog(@"***Could not create data from image destination ***");
            }
            //            image = [UIImage imageWithData:imageData];
            
            NSString *path = [NSString stringWithFormat:@"%@/temp/do_Album",_fileFullName];
            if(![doIOHelper ExistDirectory:path])
                [doIOHelper CreateDirectory:path];
            [doIOHelper WriteAllBytes:filePath :dest_data];
            
            //cleanup
            CFRelease(destination);
            CFRelease(imageSource);
            
            // finish one data write operation
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            weakSelf.countForFireSelectResult += 1;
            dispatch_semaphore_signal(semaphore);
        }];

        [urlArr addObject:[NSString stringWithFormat:@"data://temp/do_Album/%@",fileName]];
    }
    _selectedPhotoPathsArray = [NSMutableArray arrayWithArray:urlArr];
    
    if (_timerToFireSelectResult) {
        [_timerToFireSelectResult setFireDate:[NSDate distantPast]];
    }
}

- (void)imagePickerController:(doYZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    if ([asset isKindOfClass:[PHAsset class]]) { // iOS 8 以后
        PHAsset *videoAsset = (PHAsset*)asset;
       
        if (videoAsset.mediaType == PHAssetMediaTypeVideo) {
            NSString *fileRootPath = [self.myScritEngine CurrentApp].DataFS.RootPath;
            __block NSString *fileName = @"tempAssetVideo.mov";
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
            
            [picker.topViewController.view addSubview:self.interceptTouchView];
            [self.interceptTouchView addSubview:self.coverView];
            [self.coverView addSubview:self.indicatorView];
            [self.coverView addSubview:self.exportLoadingLabel];
            [self.indicatorView startAnimating];
            __weak typeof(self) weakSelf = self;
            [[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                AVURLAsset *urlAsset = (AVURLAsset*)asset;
                fileName = [urlAsset.URL.absoluteString lastPathComponent];
                NSString *PATH_MOVIE_FILE = [NSString stringWithFormat:@"%@/temp/do_Album/%@",fileRootPath,fileName];
                NSString *ExportFilePath = [NSString stringWithFormat:@"data://temp/do_Album/%@",fileName];
                
                NSString *path = [NSString stringWithFormat:@"%@/temp/do_Album",fileRootPath];
                if(![doIOHelper ExistDirectory:path]) {
                    [doIOHelper CreateDirectory:path];
                }
                doInvokeResult *result = [[doInvokeResult alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_MOVIE_FILE]) { // 视频已在本地存在
//                    [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
                    [result SetResultArray:[NSMutableArray arrayWithObjects:ExportFilePath, nil]];
                    [weakSelf.myScritEngine Callback:weakSelf.myCallbackName :result];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [weakSelf.indicatorView stopAnimating];
                        [weakSelf.indicatorView removeFromSuperview];
                        [weakSelf.exportLoadingLabel removeFromSuperview];
                        [weakSelf.coverView removeFromSuperview];
                        [self.interceptTouchView removeFromSuperview];
                        [[NSNotificationCenter defaultCenter] postNotificationName:doAblumFinishExprotVideoToLocalNotification object:nil];
                    });
                }else {
                    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
                    exportSession.outputFileType =  AVFileTypeQuickTimeMovie;
                    exportSession.outputURL = [NSURL fileURLWithPath:PATH_MOVIE_FILE];
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [weakSelf.indicatorView stopAnimating];
                            [weakSelf.indicatorView removeFromSuperview];
                            [weakSelf.exportLoadingLabel removeFromSuperview];
                            [weakSelf.coverView removeFromSuperview];
                            [[NSNotificationCenter defaultCenter] postNotificationName:doAblumFinishExprotVideoToLocalNotification object:nil];
                        });
                        if (exportSession.error == nil && exportSession.status == AVAssetExportSessionStatusCompleted) {
                            [result SetResultArray:[NSMutableArray arrayWithObjects:ExportFilePath, nil]];
                            NSLog(@"success exporting video asset");
                        }else {
                            NSLog(@"Error exporting video asset");
                            [[doServiceContainer Instance].LogEngine WriteError:nil :exportSession.error.description];
                        }
                        [weakSelf.myScritEngine Callback:weakSelf.myCallbackName :result];
                    }];
                }
            }];
        } else{
            [self.myScritEngine Callback:self.myCallbackName :[[doInvokeResult alloc] init]];
            NSLog(@"选择的asset 不是视频资源");
        }
        
    }else if ([asset isKindOfClass:[ALAsset class]]){ // iOS 7 不予支持了
        [self.myScritEngine Callback:self.myCallbackName :[[doInvokeResult alloc] init]];
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"iOS7及以下版本系统不支持选择视频"];
        NSLog(@"iOS8以下的系统不支持");

    }
}


@end
