//
//  AGIPCAssetsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "doAGIPCAssetsController.h"

#import "AGImagePickerController+Helper.h"

#import "doAGIPCGridCell.h"
#import "doAGIPCToolbarItem.h"

#import "doAGImagePreviewController.h"
#import "doAGIPCPreviewController.h"

@interface doAGIPCAssetsController ()<AGIPCPreviewControllerDelegate>
{
    ALAssetsGroup *_assetsGroup;
    NSMutableArray *_assets;
    __ag_weak doAGImagePickerController *_imagePickerController;
    
    UIInterfaceOrientation lastOrientation;
}

@property (nonatomic, strong) NSMutableArray *assets;

@end

@interface doAGIPCAssetsController (Private)

- (void)changeSelectionInformation;

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;
- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification;

- (BOOL)toolbarHidden;

- (void)loadAssets;
- (void)reloadData;

- (void)setupToolbarItems;

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)doneAction:(id)sender;
- (void)selectAllAction:(id)sender;
- (void)deselectAllAction:(id)sender;
- (void)customBarButtonItemAction:(id)sender;

@end

@implementation doAGIPCAssetsController

#pragma mark - Properties

@synthesize assetsGroup = _assetsGroup, assets = _assets, imagePickerController = _imagePickerController;

- (BOOL)toolbarHidden
{
    if (! self.imagePickerController.shouldShowToolbarForManagingTheSelection)
        return YES;
    else
    {
        if (self.imagePickerController.toolbarItemsForManagingTheSelection != nil) {
            return !(self.imagePickerController.toolbarItemsForManagingTheSelection.count > 0);
        } else {
            return NO;
        }
    }
}

- (void)setAssetsGroup:(ALAssetsGroup *)theAssetsGroup
{
    @synchronized (self)
    {
        if (_assetsGroup != theAssetsGroup)
        {
            _assetsGroup = theAssetsGroup;
            [_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];

            // modified by springox(20140510)
            //[self reloadData];
        }
    }
}

- (ALAssetsGroup *)assetsGroup
{
    ALAssetsGroup *ret = nil;
    
    @synchronized (self)
    {
        ret = _assetsGroup;
    }
    
    return ret;
}

- (NSArray *)selectedAssets
{
    NSMutableArray *selectedAssets = [NSMutableArray array];
    
	for (doAGIPCGridItem *gridItem in self.assets) 
    {		
		if (gridItem.selected)
        {	
			[selectedAssets addObject:gridItem.asset];
		}
	}
    
    return selectedAssets;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(doAGImagePickerController *)imagePickerController andAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _assets = [[NSMutableArray alloc] init];
        self.assetsGroup = assetsGroup;
        self.imagePickerController = imagePickerController;
        self.title = @"照片选择";
        
        // Setup toolbar items
        [self setupToolbarItems];
        
        // Start loading the assets
        [self loadAssets];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterFromNotifications];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (! self.imagePickerController) return 0;
    
    double numberOfAssets = (double)self.assetsGroup.numberOfAssets;
    NSInteger nr = ceil(numberOfAssets / self.imagePickerController.numberOfItemsPerRow);
    
    return nr;
}

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.imagePickerController.numberOfItemsPerRow];
    
    NSUInteger startIndex = indexPath.row * self.imagePickerController.numberOfItemsPerRow, 
                 endIndex = startIndex + self.imagePickerController.numberOfItemsPerRow - 1;
    if (startIndex < self.assets.count)
    {
        if (endIndex > self.assets.count - 1)
            endIndex = self.assets.count - 1;
        
        for (NSUInteger i = startIndex; i <= endIndex; i++)
        {
            [items addObject:(self.assets)[i]];
        }
    }
    
    return items;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.imagePickerController.itemRect.origin.y;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    // modified by springox(20141010)
    //view.backgroundColor = [UIColor whiteColor];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect itemRect = self.imagePickerController.itemRect;
    return itemRect.size.height + itemRect.origin.y;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    doAGIPCGridCell *cell = (doAGIPCGridCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {		        
        cell = [[doAGIPCGridCell alloc] initWithImagePickerController:self.imagePickerController items:[self itemsForRowAtIndexPath:indexPath] andReuseIdentifier:CellIdentifier];
    }	
	else 
    {		
		cell.items = [self itemsForRowAtIndexPath:indexPath];
	}
    
    return cell;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fullscreen
    if (self.imagePickerController.shouldChangeStatusBarStyle) {
//        self.wantsFullScreenLayout = YES;
    }
    
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Navigation Bar Items
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
//    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    doneButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    lastOrientation = self.interfaceOrientation;
    // add by springox(20141105)
    [doAGIPCGridItem performSelector:@selector(resetNumberOfSelections)];

    // modified by springox(20140510)
    [self reloadData];
    
    // Setup Notifications
    [self registerForNotifications];
    
    }

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Destroy Notifications
    [self unregisterFromNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // modified by springox(20141105)
    //// Reset the number of selections
    //[AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
    
    if (lastOrientation != self.interfaceOrientation) {
        [self reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self reloadData];
}

// add by springox(20141024)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self reloadData];
}

#pragma mark - Private

- (void)setupToolbarItems
{
//    if (self.imagePickerController.toolbarItemsForManagingTheSelection != nil)
//    {
//        NSMutableArray *items = [NSMutableArray array];
//        
//        // Custom Toolbar Items
//        for (id item in self.imagePickerController.toolbarItemsForManagingTheSelection)
//        {
//            NSAssert([item isKindOfClass:[doAGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
//            
//            ((AGIPCToolbarItem *)item).barButtonItem.target = self;
//            ((AGIPCToolbarItem *)item).barButtonItem.action = @selector(customBarButtonItemAction:);
//            
//            [items addObject:((doAGIPCToolbarItem *)item).barButtonItem];
//        }
//        
//        self.toolbarItems = items;
//    } else {
//        // Standard Toolbar Items
//        UIBarButtonItem *selectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.SelectAll", nil, [NSBundle mainBundle], @"Select All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllAction:)];
//        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        UIBarButtonItem *deselectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.DeselectAll", nil, [NSBundle mainBundle], @"Deselect All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(deselectAllAction:)];
//        
//        NSArray *toolbarItemsForManagingTheSelection = @[selectAll, flexibleSpace, deselectAll];
//        self.toolbarItems = toolbarItemsForManagingTheSelection;
//    }
}

- (void)loadAssets
{
    [self.assets removeAllObjects];
    
    __ag_weak doAGIPCAssetsController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        __strong doAGIPCAssetsController *strongSelf = weakSelf;
        
        @autoreleasepool {
            [strongSelf.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result == nil) 
                {
                    return;
                }
                if (strongSelf.imagePickerController.shouldShowPhotosWithLocationOnly) {
                    CLLocation *assetLocation = [result valueForProperty:ALAssetPropertyLocation];
                    if (!assetLocation || !CLLocationCoordinate2DIsValid([assetLocation coordinate])) {
                        return;
                    }
                }
                
                doAGIPCGridItem *gridItem = [[doAGIPCGridItem alloc] initWithImagePickerController:self.imagePickerController asset:result andDelegate:self];
                
                // Descending photos, springox(20131225)
                [strongSelf.assets addObject:gridItem];
                //[strongSelf.assets insertObject:gridItem atIndex:0];

            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [strongSelf reloadData];
            
        });
    
    });
}

- (void)reloadData
{
    // Don't display the select button until all the assets are loaded.
    [self.navigationController setToolbarHidden:[self toolbarHidden] animated:YES];
    
    [self.tableView reloadData];
    
    //[self setTitle:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    [self changeSelectionInformation];
    
    
    NSInteger totalRows = [self.tableView numberOfRowsInSection:0];
    //Prevents crash if totalRows = 0 (when the album is empty).
    if (totalRows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:totalRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)doneAction:(id)sender
{
    [self.imagePickerController performSelector:@selector(didFinishPickingAssets:) withObject:self.selectedAssets];
}

- (void)selectAllAction:(id)sender
{
    for (doAGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = YES;
    }
}

- (void)deselectAllAction:(id)sender
{
    for (doAGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = NO;
    }
}

- (void)customBarButtonItemAction:(id)sender
{
    for (id item in self.imagePickerController.toolbarItemsForManagingTheSelection)
    {
        NSAssert([item isKindOfClass:[doAGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
        
        if (((doAGIPCToolbarItem *)item).barButtonItem == sender)
        {
            if (((doAGIPCToolbarItem *)item).assetIsSelectedBlock) {
                
                NSUInteger idx = 0;
                for (doAGIPCGridItem *obj in self.assets) {
                    obj.selected = ((doAGIPCToolbarItem *)item).assetIsSelectedBlock(idx, ((doAGIPCGridItem *)obj).asset);
                    idx++;
                }
                
            }
        }
    }
}

- (void)changeSelectionInformation
{
    if (self.imagePickerController.shouldDisplaySelectionInformation ) {
        if (0 == [doAGIPCGridItem numberOfSelections] ) {
            self.navigationController.navigationBar.topItem.prompt = nil;
        } else {
            //self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
            // Display supports up to select several photos at the same time, springox(20131220)
            NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
            if (0 < maxNumber) {
                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%lu/%ld)", (unsigned long)[doAGIPCGridItem numberOfSelections], (long)maxNumber];
            } else {
                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%lu/%lu)", (unsigned long)[doAGIPCGridItem numberOfSelections], (unsigned long)self.assets.count];
            }
        }
    }
}

#pragma mark - AGGridItemDelegate Methods

- (void)agGridItem:(doAGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections
{
    self.navigationItem.rightBarButtonItem.enabled = (numberOfSelections.unsignedIntegerValue > 0);
    [self changeSelectionInformation];
}

- (BOOL)agGridItemCanSelect:(doAGIPCGridItem *)gridItem
{
    if (self.imagePickerController.selectionMode == AGImagePickerControllerSelectionModeSingle && self.imagePickerController.selectionBehaviorInSingleSelectionMode == AGImagePickerControllerSelectionBehaviorTypeRadio) {
        for (doAGIPCGridItem *item in self.assets)
            if (item.selected)
                item.selected = NO;
        return YES;
    } else {
        if (self.imagePickerController.maximumNumberOfPhotosToBeSelected > 0)
            return ([doAGIPCGridItem numberOfSelections] < self.imagePickerController.maximumNumberOfPhotosToBeSelected);
        else
            return YES;
    }
}

// add by springox(20141023)
- (void)agGridItemDidTapAction:(doAGIPCGridItem *)gridItem
{
    // mark the original orientation, springox(20141109)
    lastOrientation = self.interfaceOrientation;
    
    doAGIPCPreviewController *preController = [[doAGIPCPreviewController alloc] initWithAssets:self.assets targetAsset:gridItem];
    preController.delegate = self;
    preController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:preController animated:YES completion:^{
        // do nothing
    }];
}

#pragma mark - AGIPCPreviewControllerDelegate Methods

- (void)previewController:(doAGIPCPreviewController *)pVC didRotateFromOrientation:(UIInterfaceOrientation)fromOrientation
{
    // do noting
}
- (void)previewController:(doAGIPCPreviewController *)pVC didFinishSelected:(doAGIPCGridItem *)gridItem
{
    [self doneAction:nil];
}


#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[doAGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[doAGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification
{
    NSLog(@"here.");
}

@end
