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
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLable.attributedText = nameString;
    [[doYZImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
}

/// For fitting iOS6
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}


@end