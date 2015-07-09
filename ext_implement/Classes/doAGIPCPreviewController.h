//
//  AGIPCPreviewController.h
//  AGImagePickerController Demo
//
//  Created by SpringOx on 14/11/1.
//  Copyright (c) 2014年 Artur Grigor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AGImagePickerControllerDefines.h"

@class doAGIPCPreviewController;
@class doAGIPCGridItem;
@protocol AGIPCPreviewControllerDelegate <NSObject>

@optional
- (void)previewController:(doAGIPCPreviewController *)pVC didRotateFromOrientation:(UIInterfaceOrientation)fromOrientation;

- (BOOL)previewController:(doAGIPCPreviewController *)pVC canSelectItem:(doAGIPCGridItem *)gridItem;

- (void)previewController:(doAGIPCPreviewController *)pVC didSelectItem:(doAGIPCGridItem *)gridItem;

- (void)previewController:(doAGIPCPreviewController *)pVC didDeselectItem:(doAGIPCGridItem *)gridItem;

@end

@interface doAGIPCPreviewController : UIViewController

@property (nonatomic, strong, readonly) doAGIPCGridItem *targetAsset;

@property (nonatomic, strong, readonly) NSArray *assets;

@property (nonatomic, ag_weak) id<AGIPCPreviewControllerDelegate, NSObject> delegate;

- (id)initWithAssets:(NSArray *)assets targetAsset:(doAGIPCGridItem *)targetAsset;

@end
