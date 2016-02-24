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

@end

@implementation do_Album_SM
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
    if (_path ==nil || _path.length <=0) {//失败
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
    id<doIPage> curPage = [self.myScritEngine CurrentPage];
    
    UIViewController *curVc = (UIViewController *)curPage.PageView;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        doYZImagePickerController *imagePickerVc = [[doYZImagePickerController alloc] initWithMaxImagesCount:_imageNum delegate:self];
        imagePickerVc.allowPickingOriginalPhoto = NO;
        imagePickerVc.allowPickingVideo = NO;
        [curVc presentViewController:imagePickerVc animated:YES completion:nil];
    });
}

- (void) openDoYZCropViewController
{
    doAlbumCropViewController *vc = [[doAlbumCropViewController alloc]init];
    vc.image = self.tempImage;
    vc.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    id<doIPage> pageModel = _myScritEngine.CurrentPage;
    UIViewController * currentVC = (UIViewController *)pageModel.PageView;
    // 更改UI的操作，必须回到主线程
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
            [currentVC presentViewController:navigationController animated:YES completion:nil];
    });
}
#pragma mark - 私有方法
- (void)saveImageToLocal
{
    NSMutableArray *urlArr = [[NSMutableArray alloc]init];
    NSString *_fileFullName = [self.myScritEngine CurrentApp].DataFS.RootPath;
    
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[doUIModuleHelper stringWithUUID]];
    NSString *filePath = [NSString stringWithFormat:@"%@/temp/do_Album/%@",_fileFullName,fileName];
    
    self.tempImage = [doUIModuleHelper imageWithImageSimple:self.tempImage scaledToSize:self.imageSize];
    NSData *imageData = UIImageJPEGRepresentation(self.tempImage, self.imageQuality / 100.0);
    self.tempImage = [UIImage imageWithData:imageData];
    NSString *path = [NSString stringWithFormat:@"%@/temp/do_Album",_fileFullName];
    if(![doIOHelper ExistDirectory:path])
        [doIOHelper CreateDirectory:path];
    [doIOHelper WriteAllBytes:filePath :imageData];
    
    [urlArr addObject:[NSString stringWithFormat:@"data://temp/do_Album/%@",fileName]];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init];
    [_invokeResult SetResultArray:urlArr];
    [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
}
#pragma mark - doAlbumCropViewControllerDelegate方法

-(void)cropViewController:(doAlbumCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    self.tempImage = croppedImage;
    [self saveImageToLocal];
    [controller dismissViewControllerAnimated:YES completion:nil];
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
    NSString *_fileFullName = [self.myScritEngine CurrentApp].DataFS.RootPath;
    NSMutableArray *urlArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < photos.count ; i ++) {
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[doUIModuleHelper stringWithUUID]];
        NSString *filePath = [NSString stringWithFormat:@"%@/temp/do_Album/%@",_fileFullName,fileName];
        UIImage *image = [photos objectAtIndex:i];
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
            [self openDoYZCropViewController];
            return ;
        }
        image = [doUIModuleHelper imageWithImageSimple:image scaledToSize:size];
        NSData *imageData = UIImageJPEGRepresentation(image, _imageQuality / 100.0);
        image = [UIImage imageWithData:imageData];
        NSString *path = [NSString stringWithFormat:@"%@/temp/do_Album",_fileFullName];
        if(![doIOHelper ExistDirectory:path])
            [doIOHelper CreateDirectory:path];
        [doIOHelper WriteAllBytes:filePath :imageData];

        [urlArr addObject:[NSString stringWithFormat:@"data://temp/do_Album/%@",fileName]];
    }
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
    [_invokeResult SetResultArray:urlArr];
    [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
}
@end
