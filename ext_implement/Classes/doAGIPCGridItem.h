//
//  AGIPCGridItem.h
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

#import "doAGImagePickerController.h"

@class doAGIPCGridItem;

@protocol AGIPCGridItemDelegate <NSObject>

@optional
- (void)agGridItem:(doAGIPCGridItem *)gridItem didChangeSelectionState:(NSNumber *)selected;
- (void)agGridItem:(doAGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections;
- (BOOL)agGridItemCanSelect:(doAGIPCGridItem *)gridItem;
// add by springox(20140520)
- (void)agGridItemDidTapAction:(doAGIPCGridItem *)gridItem;
@end

@interface doAGIPCGridItem : UIView
{

}

@property (assign) BOOL selected;
@property (strong) ALAsset *asset;
@property (ag_weak) id<AGIPCGridItemDelegate> delegate;
// change strong to weak, springox(20140422)
@property (ag_weak) doAGImagePickerController *imagePickerController;

- (id)initWithImagePickerController:(doAGImagePickerController *)imagePickerController andAsset:(ALAsset *)asset;
- (id)initWithImagePickerController:(doAGImagePickerController *)imagePickerController asset:(ALAsset *)asset andDelegate:(id<AGIPCGridItemDelegate>)delegate;

- (void)loadImageFromAsset;

- (void)tap:(id)sender;

+ (NSUInteger)numberOfSelections;

@end
