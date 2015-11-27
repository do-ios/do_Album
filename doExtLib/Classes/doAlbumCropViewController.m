//
//  PECropViewController.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "doAlbumCropViewController.h"
#import "doAlbumCropView.h"

@interface doAlbumCropViewController () <UIActionSheetDelegate>
{
    UINavigationBar* titleNavbar;
}

@property (nonatomic) doAlbumCropView *cropView;
@property (nonatomic) UIActionSheet *actionSheet;

@end

@implementation doAlbumCropViewController


- (void)loadView
{
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    
    self.cropView = [[doAlbumCropView alloc] initWithFrame:contentView.bounds];
    [contentView addSubview:self.cropView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"图片裁剪";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];

    
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                                   target:nil
//                                                                                   action:nil];
//    UIBarButtonItem *constrainButton = [[UIBarButtonItem alloc] initWithTitle:@"图片裁剪"
//                                                                        style:UIBarButtonItemStyleBordered
//                                                                       target:self
//                                                                       action:nil];
//    self.toolbarItems = @[flexibleSpace, constrainButton, flexibleSpace];
//    self.navigationController.toolbarHidden = NO;
//
////    titleNavbar = [[UINavigationBar alloc] init];
////    [self.view addSubview:titleNavbar];
    self.cropView.image = self.image;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [titleNavbar setFrame :CGRectMake(0, 0, self.view.frame.size.width, 64)];
//    UINavigationItem *barItem = [[UINavigationItem alloc]initWithTitle:@"图片裁剪"];
//    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
//    UIBarButtonItem *righ = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
//    [barItem setLeftBarButtonItem:left animated:NO];
//    [barItem setRightBarButtonItem:righ animated:NO];
//    [titleNavbar pushNavigationItem:barItem animated:NO];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.cropView.image = image;
}

- (void)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancel:)]) {
        [self.delegate cropViewControllerDidCancel:self];
    }
}

- (void)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCroppingImage:)]) {
        [self.delegate cropViewController:self didFinishCroppingImage:self.cropView.croppedImage];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        CGRect cropRect = self.cropView.cropRect;
        CGSize size = self.cropView.image.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat ratio;
        if (width < height) {
            ratio = width / height;
            cropRect.size = CGSizeMake(CGRectGetHeight(cropRect) * ratio, CGRectGetHeight(cropRect));
        } else {
            ratio = height / width;
            cropRect.size = CGSizeMake(CGRectGetWidth(cropRect), CGRectGetWidth(cropRect) * ratio);
        }
        self.cropView.cropRect = cropRect;
    } else if (buttonIndex == 1) {
        self.cropView.aspectRatio = 1.0f;
    } else if (buttonIndex == 2) {
        self.cropView.aspectRatio = 2.0f / 3.0f;
    } else if (buttonIndex == 3) {
        self.cropView.aspectRatio = 3.0f / 5.0f;
    } else if (buttonIndex == 4) {
        CGFloat ratio = 3.0f / 4.0f;
        CGRect cropRect = self.cropView.cropRect;
        CGFloat width = CGRectGetHeight(cropRect);
        cropRect.size = CGSizeMake(width, width * ratio);
        self.cropView.cropRect = cropRect;
    } else if (buttonIndex == 5) {
        self.cropView.aspectRatio = 4.0f / 6.0f;
    } else if (buttonIndex == 6) {
        self.cropView.aspectRatio = 5.0f / 7.0f;
    } else if (buttonIndex == 7) {
        self.cropView.aspectRatio = 8.0f / 10.0f;
    } else if (buttonIndex == 8) {
        CGFloat ratio = 9.0f / 16.0f;
        CGRect cropRect = self.cropView.cropRect;
        CGFloat width = CGRectGetHeight(cropRect);
        cropRect.size = CGSizeMake(width, width * ratio);
        self.cropView.cropRect = cropRect;
    }
}

@end
