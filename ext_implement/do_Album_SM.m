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
#import "YZAlbumMultipleViewController.h"
#import "doIApp.h"
#import "doIDataFS.h"
#import "doIOHelper.h"
#import "doJsonHelper.h"

@interface do_Album_SM()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,copy) NSString *myCallbackName;
@property(nonatomic,weak) id<doIScriptEngine> myScritEngine;
@property(nonatomic,strong) UIImagePickerController *imagePickerVC;
@property(nonatomic,strong) UIPopoverController *popController;
@property(nonatomic,assign) int imageNum;
@property(nonatomic,assign) int imageWidth;
@property(nonatomic,assign) int imageHeight;
@property(nonatomic,assign) int imageQuality;
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
    _imageWidth = [doJsonHelper GetOneInteger:_dictParas :@"width" :-1];
    _imageHeight = [doJsonHelper GetOneInteger:_dictParas :@"height" :-1];
    _imageQuality = [doJsonHelper GetOneInteger:_dictParas :@"quality" :100];
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
        if (_imageWidth >=0 && _imageHeight >= 0) {//设置图片大小
            imageTemp = [doUIModuleHelper imageWithImageSimple:imageTemp scaledToSize:CGSizeMake(_imageWidth, _imageHeight)];
        }
        if(_imageQuality > 100)_imageQuality  = 100;
        if(_imageQuality<0)_imageQuality = 1;
        NSData *imageData = UIImageJPEGRepresentation(imageTemp, _imageQuality/100);
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
    id<doIPage> curPage = [self.myScritEngine CurrentPage];
    NSLog(@"%d---%d---",_imageWidth,_imageHeight);
    if (_imageWidth == 0&& _imageHeight ==0) {//对于不填的处理
        _imageWidth = -1;
        _imageHeight = -1;
    }
    UIViewController *curVc = (UIViewController *)curPage.PageView;
    if (_imageNum == 1)
    {
        [self singleSelectImage:curVc];
    }
    else
    {
        [self multipleSelecteImage:curVc withNum:_imageNum withImageQuality:_imageQuality withImageWidth:_imageWidth withImageHeight:_imageHeight];
    }
}

- (void)singleSelectImage:(UIViewController *)currentVc
{
    _imagePickerVC = [[UIImagePickerController alloc]init];
    _imagePickerVC.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        _imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        dispatch_async(dispatch_get_main_queue(), ^{
           [currentVc presentViewController:_imagePickerVC animated:YES completion:nil];
        });
    }
}
- (void)multipleSelecteImage:(UIViewController *)currentVc withNum:(int)imageNum withImageQuality:(int)imageQuality withImageWidth:(int)imageHeight withImageHeight:(int)imageWidth
{
    YZAlbumMultipleViewController *albummultipleVc = [[YZAlbumMultipleViewController alloc]init];
    albummultipleVc.num = imageNum;
    UINavigationController *naVc = [[UINavigationController alloc]initWithRootViewController:albummultipleVc];
    albummultipleVc.cancelSelectBlock = ^(NSError *error)
    {
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        [_invokeResult SetError:@"错误"];
        [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
    };
    if(imageQuality > 100)imageQuality  = 100;
    if(imageQuality<0)imageQuality = 1;
    
    albummultipleVc.selectSucessBlock = ^(NSMutableArray *selectImageArr)
    {
        NSString *_fileFullName = [self.myScritEngine CurrentApp].DataFS.RootPath;
        NSMutableArray *urlArr = [[NSMutableArray alloc]init];
        for (int i = 0; i < selectImageArr.count ; i ++) {
            ALAsset *asset = [selectImageArr objectAtIndex:i];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[doUIModuleHelper stringWithUUID]];
            NSString *filePath = [NSString stringWithFormat:@"%@/tmp/do_Album/%@",_fileFullName,fileName];
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation]fullResolutionImage]];
            CGSize size = CGSizeMake(imageWidth, imageHeight);;
            CGFloat hwRatio = image.size.height/image.size.width;
            CGFloat whRatio = image.size.width/image.size.height;
            if (-1 == imageHeight && -1 == imageWidth) {//保持原始比例
                size = CGSizeMake(image.size.width, image.size.height);
            }
            else
            {
                if(-1 == imageWidth)
                {
                    size = CGSizeMake(imageHeight*whRatio, imageHeight);
                }
                if(-1 == imageHeight)
                {
                    size = CGSizeMake(imageWidth, imageWidth*hwRatio);
                }
            }
            image = [doUIModuleHelper imageWithImageSimple:image scaledToSize:size];
            NSData *imageData = UIImageJPEGRepresentation(image, imageQuality / 100.0);
            image = [UIImage imageWithData:imageData];
            NSString *path = [NSString stringWithFormat:@"%@/tmp/do_Album",_fileFullName];
            if(![doIOHelper ExistDirectory:path])
                [doIOHelper CreateDirectory:path];
            [doIOHelper WriteAllBytes:filePath :imageData];
            
            [urlArr addObject:[NSString stringWithFormat:@"data://tmp/do_Album/%@",fileName]];
        }
        doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
        [_invokeResult SetResultArray:urlArr];
        [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentVc presentViewController:naVc animated:YES completion:nil];
    });

}

#pragma -mark -
#pragma -mark UIImagePickerControllerDelegate代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = nil;
    //当选择的类型是图片
    if ([mediaType isEqualToString:@"public.image"]){
        if ([info objectForKey:UIImagePickerControllerEditedImage]){
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        @try {
            NSString *_fileFullName = [self.myScritEngine CurrentApp].DataFS.RootPath;
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[doUIModuleHelper stringWithUUID]];
            NSString *filePath = [NSString stringWithFormat:@"%@/tmp/do_Album/%@",_fileFullName,fileName];
            CGSize size = CGSizeMake(_imageWidth, _imageHeight);;
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
            image = [doUIModuleHelper imageWithImageSimple:image scaledToSize:size];
            NSData *imageData = UIImageJPEGRepresentation(image, _imageQuality / 100.0);
            image = [UIImage imageWithData:imageData];
            NSString *path = [NSString stringWithFormat:@"%@/tmp/do_Album",_fileFullName];
            if(![doIOHelper ExistDirectory:path])
            {
                [doIOHelper CreateDirectory:path];
            }
            [doIOHelper WriteAllBytes:filePath :imageData];
            doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
            [_invokeResult SetResultText:[NSString stringWithFormat:@"data://tmp/do_Album/%@",fileName]];
            [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
        }
        @catch (NSException *exception) {
            @throw [NSException exceptionWithName:@"do_Album" reason:@"获取照片错误!" userInfo:nil];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    [_invokeResult SetError:@"取消选择"];
    [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];

}

@end
