//
//  AGIPCGridCell.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "doAGIPCGridCell.h"
#import "doAGIPCGridItem.h"

#import "doAGImagePickerController.h"
#import "AGImagePickerController+Helper.h"

@interface doAGIPCGridCell ()
{
	NSArray *_items;
    __ag_weak doAGImagePickerController *_imagePickerController;
}

@end

@implementation doAGIPCGridCell

#pragma mark - Properties

@synthesize items = _items, imagePickerController = _imagePickerController;

- (void)setItems:(NSArray *)items
{
    @synchronized (self)
    {
        if (_items != items)
        {
            for (doAGIPCGridItem *gridItem in items) {
                [gridItem removeFromSuperview];
            }
            
            for (UIView *view in [self.contentView subviews])
            {
                [view removeFromSuperview];
            }
            
            _items = items;

            for (doAGIPCGridItem *gridItem in _items)
            {
                [self.contentView addSubview:gridItem];
            }
        }
    }
}

- (NSArray *)items
{
    NSArray *array = nil;
    
    @synchronized (self)
    {
        array = _items;
    }
    
    return array;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(doAGImagePickerController *)imagePickerController items:(NSArray *)items andReuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self)
    {
        self.imagePickerController = imagePickerController;
		self.items = items;
        
        // modified by springox(20141012)
        //UIView *emptyView = [[UIView alloc] init];
        //self.backgroundView = emptyView;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    CGRect frame = self.imagePickerController.itemRect;
    
    //CGRect contentFrame = self.contentView.frame;
    CGRect contentFrame = self.bounds;
    contentFrame.size.height = ceilf(frame.origin.y) + ceilf(frame.size.height);
    self.contentView.frame = contentFrame;
    
    CGFloat leftMargin = frame.origin.x;
    for (doAGIPCGridItem *gridItem in self.items)
    {
        // Load image with asset when layout grid items. springox(20131218)
        [gridItem loadImageFromAsset];
        
        [gridItem setFrame:frame];
        UITapGestureRecognizer *selectionGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:gridItem action:@selector(tap:)];
        selectionGestureRecognizer.numberOfTapsRequired = 1;
        [gridItem addGestureRecognizer:selectionGestureRecognizer];
        
        frame.origin.x = frame.origin.x + frame.size.width + leftMargin;
    }
}

@end
