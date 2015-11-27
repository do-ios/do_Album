//
//  PECropRectView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/21.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class doAlbumCropRectView;
@protocol doYZCropRectViewDelegate <NSObject>

- (void)cropRectViewDidBeginEditing:(doAlbumCropRectView *)cropRectView;
- (void)cropRectViewEditingChanged:(doAlbumCropRectView *)cropRectView;
- (void)cropRectViewDidEndEditing:(doAlbumCropRectView *)cropRectView;

@end

@interface doAlbumCropRectView : UIView

@property (nonatomic,weak) id <doYZCropRectViewDelegate> delegate;
@property (nonatomic,assign) BOOL showsGridMajor;
@property (nonatomic,assign) BOOL showsGridMinor;

@end


