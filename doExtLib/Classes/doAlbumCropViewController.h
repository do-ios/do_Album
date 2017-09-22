//
//  PECropViewController.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol doAlbumCropViewControllerDelegate;

@interface doAlbumCropViewController : UIViewController
@property (nonatomic,weak) id<doAlbumCropViewControllerDelegate> delegate;
@property (nonatomic,assign) UIImage *image;
@property (nonatomic, strong) id asset;

@end

@protocol doAlbumCropViewControllerDelegate <NSObject>

- (void)cropViewController:(doAlbumCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
- (void)cropViewControllerDidCancel:(doAlbumCropViewController *)controller;

@end
