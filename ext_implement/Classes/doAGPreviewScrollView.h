//
//  AGPreviewScrollView.h
//  AGImagePickerController Demo
//
//  Created by SpringOx on 14/11/1.
//  Copyright (c) 2014年 Artur Grigor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AGImagePickerControllerDefines.h"

@class doAGPreviewScrollView;

@protocol AGPreviewScrollViewDelegate <NSObject>

- (NSInteger)previewScrollViewNumberOfImage:(doAGPreviewScrollView *)scrollView;

- (CGSize)previewScrollViewSizeOfImage:(doAGPreviewScrollView *)scrollView;

- (NSUInteger)previewScrollViewCurrentIndexOfImage:(doAGPreviewScrollView *)scrollView;

- (UIImage *)previewScrollView:(doAGPreviewScrollView *)scrollView imageAtIndex:(NSUInteger)index;

- (void)previewScrollView:(doAGPreviewScrollView *)scrollView didScrollWithCurrentIndex:(NSUInteger)index;

@end

@interface doAGPreviewScrollView : UIScrollView

@property (nonatomic, ag_weak) id<AGPreviewScrollViewDelegate, NSObject> preDelegate;

- (id)initWithFrame:(CGRect)frame preDelegate:(id)preDelegate;

- (NSInteger)currentIndexOfImage;

- (void)resetContentViews;

@end
