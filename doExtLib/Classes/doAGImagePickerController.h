//
//  AGImagePickerController.h
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

#import "AGImagePickerControllerDefines.h"

@class doAGImagePickerController;

@protocol AGImagePickerControllerDelegate

@optional

#pragma mark - Configuring Rows
- (NSUInteger)agImagePickerController:(doAGImagePickerController *)picker
   numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
        andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

#pragma mark - Configuring Selections
- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(doAGImagePickerController *)picker;

#pragma mark - Appearance Configuration
- (BOOL)agImagePickerController:(doAGImagePickerController *)picker
shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode;
- (BOOL)agImagePickerController:(doAGImagePickerController *)picker
shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode;

#pragma mark - Managing Selections
- (void)agImagePickerController:(doAGImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)agImagePickerController:(doAGImagePickerController *)picker didFail:(NSError *)error;

@end

@interface doAGImagePickerController : UINavigationController
{
    id __ag_weak _pickerDelegate;
    
    struct {
        unsigned int delegateSelectionBehaviorInSingleSelectionMode:1;
        unsigned int delegateNumberOfItemsPerRowForDevice:1;
        unsigned int delegateShouldDisplaySelectionInformationInSelectionMode:1;
        unsigned int delegateShouldShowToolbarForManagingTheSelectionInSelectionMode:1;
        unsigned int delegateDidFinishPickingMediaWithInfo:1;
        unsigned int delegateDidFail:1;
    } _pickerFlags;
    
    BOOL _shouldChangeStatusBarStyle;
    BOOL _shouldShowSavedPhotosOnTop;
    UIStatusBarStyle _oldStatusBarStyle;
    
    AGIPCDidFinish _didFinishBlock;
    AGIPCDidFail _didFailBlock;
    
    NSUInteger _maximumNumberOfPhotosToBeSelected;
    
    NSArray *_toolbarItemsForManagingTheSelection;
    NSArray *_selection;
}

@property (nonatomic) BOOL shouldChangeStatusBarStyle;
@property (nonatomic) BOOL shouldShowSavedPhotosOnTop;
@property (nonatomic) BOOL shouldShowPhotosWithLocationOnly;
@property (nonatomic) NSUInteger maximumNumberOfPhotosToBeSelected;

@property (nonatomic, ag_weak) id delegate;

@property (nonatomic, copy) AGIPCDidFail didFailBlock;
@property (nonatomic, copy) AGIPCDidFinish didFinishBlock;

@property (nonatomic, strong) NSArray *toolbarItemsForManagingTheSelection;
@property (nonatomic, strong) NSArray *selection;

@property (nonatomic, readonly) AGImagePickerControllerSelectionMode selectionMode;

@property (nonatomic, assign) BOOL userIsDenied;

+ (ALAssetsLibrary *)defaultAssetsLibrary;

+ (doAGImagePickerController *)sharedInstance:(id)delegate;

- (id)initWithDelegate:(id)delegate;
- (id)initWithFailureBlock:(AGIPCDidFail)failureBlock
           andSuccessBlock:(AGIPCDidFinish)successBlock;
- (id)initWithDelegate:(id)delegate
          failureBlock:(AGIPCDidFail)failureBlock
          successBlock:(AGIPCDidFinish)successBlock
maximumNumberOfPhotosToBeSelected:(NSUInteger)maximumNumberOfPhotosToBeSelected
shouldChangeStatusBarStyle:(BOOL)shouldChangeStatusBarStyle
toolbarItemsForManagingTheSelection:(NSArray *)toolbarItemsForManagingTheSelection
andShouldShowSavedPhotosOnTop:(BOOL)shouldShowSavedPhotosOnTop;

- (void)showFirstAssetsController;

@end


