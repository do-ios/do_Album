//
//  AGIPCAlbumsController.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "doAGImagePickerController.h"

@interface doAGIPCAlbumsController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (ag_weak, readonly) NSMutableArray *assetsGroups;
// change strong to weak, springox(20140422)
@property (ag_weak) doAGImagePickerController *imagePickerController;

- (id)initWithImagePickerController:(doAGImagePickerController *)imagePickerController;

- (void)pushFirstAssetsController;

@end
