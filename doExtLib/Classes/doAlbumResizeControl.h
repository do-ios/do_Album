//
//  PEResizeControl.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface doAlbumResizeControl : UIView

@property (weak, nonatomic) id delegate;
@property (nonatomic, readonly) CGPoint translation;

@end

@protocol PEResizeConrolViewDelegate <NSObject>

- (void)resizeConrolViewDidBeginResizing:(doAlbumResizeControl *)resizeConrolView;
- (void)resizeConrolViewDidResize:(doAlbumResizeControl *)resizeConrolView;
- (void)resizeConrolViewDidEndResizing:(doAlbumResizeControl *)resizeConrolView;

@end
