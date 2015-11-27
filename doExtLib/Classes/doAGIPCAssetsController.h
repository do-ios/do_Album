//
//  AGIPCAssetsController.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

#import "doAGImagePickerController.h"
#import "doAGIPCGridItem.h"

@interface doAGIPCAssetsController : UITableViewController<UITableViewDataSource, UITableViewDelegate, AGIPCGridItemDelegate>

@property (strong) ALAssetsGroup *assetsGroup;
@property (ag_weak, readonly) NSArray *selectedAssets;
// change strong to weak, springox(20140422)
@property (ag_weak) doAGImagePickerController *imagePickerController;

- (id)initWithImagePickerController:(doAGImagePickerController *)imagePickerController andAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end
