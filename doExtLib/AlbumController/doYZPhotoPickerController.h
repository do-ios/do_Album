//
//  TZPhotoPickerController.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "doYZImagePickerController.h"
@class doYZAlbumModel;
@interface doYZPhotoPickerController : UIViewController

@property (nonatomic, strong) doYZAlbumModel *model;
@property (nonatomic, assign) doYZAlbumType albumType;
@end
