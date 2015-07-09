//
//  AGIPCPreviewController.m
//  AGImagePickerController Demo
//
//  Created by SpringOx on 14/11/1.
//  Copyright (c) 2014年 Artur Grigor. All rights reserved.
//

#import "doAGIPCPreviewController.h"

#import "doAGIPCGridItem.h"
#import "doAGPreviewScrollView.h"
#import "doAGImagePreviewController.h"
#import "UIButton+AGIPC.h"

@interface doAGIPCPreviewController ()<AGPreviewScrollViewDelegate>

@property (nonatomic, strong) doAGPreviewScrollView *preScrollView;

@property (nonatomic, strong) UIView *bottomBgView;

@property (nonatomic, strong) UIButton *bottomLeftBtn;

@property (nonatomic, strong) UIButton *bottomMiddleBtn;

@property (nonatomic, strong) UIButton *bottomRightBtn;

@end

@implementation doAGIPCPreviewController

- (id)initWithAssets:(NSArray *)assets targetAsset:(doAGIPCGridItem *)targetAsset
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _assets = assets;
        _targetAsset = targetAsset;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBottomView];
    [self setScrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setBottomView];
    [self setScrollView];
    
    [_preScrollView resetContentViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if ([_delegate respondsToSelector:@selector(previewController:didRotateFromOrientation:)]) {
        [_delegate previewController:self didRotateFromOrientation:fromInterfaceOrientation];
    }
}

- (void)setBottomView
{
    if (nil == _bottomBgView) {
        /*TopBgView*/
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"do_Album.bundle/AGIPC-Bar-bg"]];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _bottomBgView = bgView;
    }
    _bottomBgView.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    [self.view addSubview:_bottomBgView];
    
    if (nil == _bottomLeftBtn) {
        /*Left Top Button*/
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.backgroundColor = [UIColor clearColor];
        [leftBtn setImage:[UIImage imageNamed:@"do_Album.bundle/AGIPC-Bar-back"] forState:UIControlStateNormal];
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -80, 0, 0);
        [leftBtn addTarget:self action:@selector(didPressBottomLeftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _bottomLeftBtn = leftBtn;
    }
    _bottomLeftBtn.frame = CGRectMake(0, 0, 120, 44);
    [_bottomBgView addSubview:_bottomLeftBtn];
    
//    if (nil == _bottomMiddleBtn) {
//        /*Right Top Button*/
//        UIButton *middleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        //middleBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        middleBtn.backgroundColor = [UIColor clearColor];
//        [middleBtn setTitle:@"Zoom" forState:UIControlStateNormal];
//        [middleBtn addTarget:self action:@selector(didPressBottomMiddleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        _bottomMiddleBtn = middleBtn;
//    }
//    _bottomMiddleBtn.frame = CGRectMake((_bottomBgView.frame.size.width-100)/2, 0, 100, 44);
//    [_bottomBgView addSubview:_bottomMiddleBtn];
    
    if (nil == _bottomRightBtn) {
        /*Right Top Button*/
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        rightBtn.backgroundColor = [UIColor clearColor];
        [rightBtn setImage:[UIImage imageNamed:@"do_Album.bundle/AGIPC-Checkmark-0"] forState:UIControlStateNormal];
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [rightBtn addTarget:self action:@selector(didPressBottomRightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _bottomRightBtn = rightBtn;
    }
    _bottomRightBtn.frame = CGRectMake(_bottomBgView.frame.size.width-70, 0, 90, 44);
    [_bottomBgView addSubview:_bottomRightBtn];
}

- (void)setScrollView
{
    if (nil == _preScrollView) {
        _preScrollView = [[doAGPreviewScrollView alloc] initWithFrame:self.view.bounds preDelegate:self];
        _preScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _preScrollView.bounces = NO;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGestureRecognizer)];
        [_preScrollView addGestureRecognizer:tapGesture];
    }
    [self.view insertSubview:_preScrollView belowSubview:_bottomBgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateBottomRightButtonState:(int)state
{
    if (2 == state) {  // with animation
        [_bottomRightBtn setImageWithAnimation:[UIImage imageNamed:@"do_Album.bundle/AGIPC-Checkmark-1"] forState:UIControlStateNormal];
    } else if (1 == state) {  // without animation
        [_bottomRightBtn setImage:[UIImage imageNamed:@"do_Album.bundle/AGIPC-Checkmark-1"] forState:UIControlStateNormal];
    } else {
        [_bottomRightBtn setImage:[UIImage imageNamed:@"do_Album.bundle/AGIPC-Checkmark-0"] forState:UIControlStateNormal];
    }
}

- (void)didTapGestureRecognizer
{
    [self didPressBottomLeftButtonAction:nil];
}

- (void)didPressBottomLeftButtonAction:(id)sender
{
    if (nil != self.navigationController && 1 < [self.navigationController.viewControllers count]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didPressBottomMiddleButtonAction:(id)sender
{
    NSInteger index = [_preScrollView currentIndexOfImage];
    if ([_assets count] <= index) {
        return;
    }
    
    doAGIPCGridItem *gridItem = [_assets objectAtIndex:index];
    ALAsset *asset = gridItem.asset;
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    doAGImagePreviewController *preController = [[doAGImagePreviewController alloc] initWithImage:image];
    preController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:preController animated:YES completion:^{
        // do nothing
    }];
}

- (void)didPressBottomRightButtonAction:(id)sender
{
    NSInteger index = _preScrollView.currentIndexOfImage;
    if ([_assets count] <= index) {
        return;
    }
    
    doAGIPCGridItem *gridItem = [_assets objectAtIndex:index];
    gridItem.selected = !gridItem.selected;
    if (gridItem.selected) {
        [self updateBottomRightButtonState:2];
    } else {
        [self updateBottomRightButtonState:0];
    }
}

#pragma mark - AGPreviewScrollViewDelegate

- (NSInteger)previewScrollViewNumberOfImage:(doAGPreviewScrollView *)scrollView
{
    return [_assets count];
}

- (CGSize)previewScrollViewSizeOfImage:(doAGPreviewScrollView *)scrollView
{
    return self.view.bounds.size;
}

- (NSUInteger)previewScrollViewCurrentIndexOfImage:(doAGPreviewScrollView *)scrollView
{
    return [_assets indexOfObject:_targetAsset];
}

- (UIImage *)previewScrollView:(doAGPreviewScrollView *)scrollView imageAtIndex:(NSUInteger)index
{
    if ([_assets count] <= index) {
        return nil;
    }
    
    doAGIPCGridItem *gridItem = [_assets objectAtIndex:index];
    ALAsset *asset = gridItem.asset;
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    return image;
}

- (void)previewScrollView:(doAGPreviewScrollView *)scrollView didScrollWithCurrentIndex:(NSUInteger)index
{
    if ([_assets count] <= index) {
        return;
    }
    
    doAGIPCGridItem *gridItem = [_assets objectAtIndex:index];
    if (gridItem.selected) {
        [self updateBottomRightButtonState:1];
    } else {
        [self updateBottomRightButtonState:0];
    }
}

@end
