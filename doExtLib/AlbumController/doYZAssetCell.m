//
//  TZAssetCell.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "doYZAssetCell.h"
#import "doYZAssetModel.h"
#import "UIView+Layout.h"
#import "doYZImageManager.h"
#import "doYZImagePickerController.h"

@interface doYZAssetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;       // The photo / 照片
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;

@end

@implementation doYZAssetCell

- (void)awakeFromNib {
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];
}

- (void)setModel:(doYZAssetModel *)model {
    _model = model;
    [[doYZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.imageView.image = photo;
    }];
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"do_Album.bundle/photo_sel_photoPickerVc"] : [UIImage imageNamed:@"do_Album.bundle/photo_def_photoPickerVc"];
    self.type = TZAssetCellTypePhoto;
    if (model.type == TZAssetModelMediaTypeLivePhoto)      self.type = TZAssetCellTypeLivePhoto;
    else if (model.type == TZAssetModelMediaTypeAudio)     self.type = TZAssetCellTypeAudio;
    else if (model.type == TZAssetModelMediaTypeVideo) {
        self.type = TZAssetCellTypeVideo;
        self.timeLength.text = model.timeLength;
    }
}

- (void)setType:(TZAssetCellType)type {
    _type = type;
    if (type == TZAssetCellTypePhoto || type == TZAssetCellTypeLivePhoto) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
    }
}

- (IBAction)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"do_Album.bundle/photo_sel_photoPickerVc"] : [UIImage imageNamed:@"do_Album.bundle/photo_def_photoPickerVc"];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:TZOscillatoryAnimationToBigger];
    }
}
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}

@end

@interface doYZAlbumCell ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@end

@implementation doYZAlbumCell

- (void)awakeFromNib {
    self.posterImageView.clipsToBounds = YES;
}

- (void)setModel:(doYZAlbumModel *)model {
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    NSInteger count = 0;
    
    if (iOS8Later) {
        NSInteger videoPHAssetCount = [(PHFetchResult*)model.result countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        NSInteger imagePHAssetCount = [(PHFetchResult*)model.result countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        PHAsset *asset;
        switch (_albumType) {
            case doYZAlbumAll: {
                asset = [model.result lastObject];
                count = model.count;
                break;
            }
            case doYZAlbumVideo: { // 用户设置当前仅选择视频
                if (model.typeOfContainPHAsset == doYZAlbumVideo) { // 当前model.phfetchResult 仅包含视频
                    asset = [model.result lastObject];
                    count = model.count;
                }else if (model.typeOfContainPHAsset == doYZAlbumAll){ // 当前model.phfetchResult 即包含视频也包含相片
                    // 找到最后一个视频的PHAsset
                    asset = [self getLastVideoPHAssetOfPHFetchResult:model.result];
                    count = videoPHAssetCount;
                }
                break;
            }
            case doYZAlbumPhoto: {
                if (model.typeOfContainPHAsset == doYZAlbumPhoto) { // 当前model.phfetchResult 仅包含图片
                    asset = [model.result lastObject];
                    count = model.count;
                }else if (model.typeOfContainPHAsset == doYZAlbumAll){ // 当前model.phfetchResult 即包含视频也包含相片
                    // 找到最后一个图片的PHAsset
                    asset = [self getLastPhotoPHAssetOfPHFetchResult:model.result];
                    count = imagePHAssetCount;
                }
                break;
            }
            default: {
                break;
            }
        }
        [[doYZImageManager manager] getPostImageWithPHAsset:asset completion:^(UIImage *postImage) {
            self.posterImageView.image = postImage;
        }];
    }else {
        [[doYZImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
            self.posterImageView.image = postImage;
        }];
        count = model.count;
    }
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLable.attributedText = nameString;
}

/// For fitting iOS6
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}

- (PHAsset*)getLastVideoPHAssetOfPHFetchResult:(PHFetchResult*)fetchResult {
    PHAsset *asset;
    NSInteger maxVideoAssetIndex = 0;
    for (PHAsset *asset in fetchResult) {
        NSInteger tempIndex;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
           tempIndex = [fetchResult indexOfObject:asset];
            if (tempIndex > maxVideoAssetIndex) {
                maxVideoAssetIndex = tempIndex;
            }
        }
    }
    asset = [fetchResult objectAtIndex:maxVideoAssetIndex];
    return asset;
}
- (PHAsset*)getLastPhotoPHAssetOfPHFetchResult:(PHFetchResult*)fetchResult {
    PHAsset *asset;
    NSInteger maxImageAssetIndex = 0;
    for (PHAsset *asset in fetchResult) {
        NSInteger tempIndex;
        if (asset.mediaType == PHAssetMediaTypeImage) {
            tempIndex = [fetchResult indexOfObject:asset];
            if (tempIndex > maxImageAssetIndex) {
                maxImageAssetIndex = tempIndex;
            }
        }
    }
    asset = [fetchResult objectAtIndex:maxImageAssetIndex];
    return asset;
}

@end
