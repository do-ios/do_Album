//
//  TZVideoPlayerController.h
//  TZImagePickerController
//
//  Created by 谭真 on 16/1/5.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const doAblumFinishExprotVideoToLocalNotification = @"doAblumFinishExprotVideoToLocalNotification";

@class doYZAssetModel;
@interface doYZVideoPlayerController : UIViewController

@property (nonatomic, strong) doYZAssetModel *model;

@end
