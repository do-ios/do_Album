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
    NSInteger imageNum = [doJsonHelper GetOneInteger:_dictParas :@"maxCount" :9];
    NSInteger imageWidth = [doJsonHelper GetOneInteger:_dictParas :@"width" :-1];
    NSInteger imageHeight = [doJsonHelper GetOneInteger:_dictParas :@"height" :-1];
    NSInteger imageQuality = [doJsonHelper GetOneInteger:_dictParas :@"quality" :100];
    
    id<doIPage> curPage = [self.myScritEngine CurrentPage];
    
    UIViewController *curVc = (UIViewController *)curPage.PageView;
    
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
        NSString *_fileFullName = [self.myScritEngine CurrentApp].DataFS.PathPrivateTemp;
        NSMutableArray *urlArr = [[NSMutableArray alloc]init];
        for (int i = 0; i < selectImageArr.count ; i ++) {
            ALAsset *asset = [selectImageArr objectAtIndex:i];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[doUIModuleHelper stringWithUUID]];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",_fileFullName,fileName];
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation]fullResolutionImage]];
            CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*(image.size.height/image.size.width));
            if (-1 == imageHeight && -1 == imageWidth) {//保持原始比例
                size = CGSizeMake(imageWidth, imageHeight);
            }
            else
            {
                if(-1 == imageWidth)
                {
                    size = CGSizeMake(imageWidth, size.height);
                }
                if(-1 == imageHeight)
                {
                    size = CGSizeMake(size.width, imageHeight);
                }
            }
            image = [doUIModuleHelper imageWithImageSimple:image scaledToSize:size];
            NSData *imageData = UIImageJPEGRepresentation(image, imageQuality / 100.0);
            image = [UIImage imageWithData:imageData];
            [doIOHelper WriteAllBytes:filePath :imageData];
            
            [urlArr addObject:[NSString stringWithFormat:@"data://temp/do_Album/%@",fileName]];
        }
        doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
        [_invokeResult SetResultArray:urlArr];
        [self.myScritEngine Callback:self.myCallbackName :_invokeResult];
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [curVc presentViewController:naVc animated:YES completion:nil];
    });
}
#pragma -mark -
#pragma -mark UIImagePickerControllerDelegate代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

@end


















