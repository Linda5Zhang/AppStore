//
//  MyCustomCollectionViewCell.h
//  AppStore2
//
//  Created by yueling zhang on 4/26/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *starsLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *genresLabel;
@property (weak, nonatomic) IBOutlet UIImageView *screenShotImageView;


@property (weak, nonatomic) IBOutlet UIImageView *favIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *favAppName;
@property (weak, nonatomic) IBOutlet UILabel *favDevName;
@property (weak, nonatomic) IBOutlet UILabel *favStars;
@property (weak, nonatomic) IBOutlet UILabel *favDescription;
@property (weak, nonatomic) IBOutlet UITextView *favDescripTextView;


@property (weak, nonatomic) IBOutlet UIImageView *detailIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *detailAppName;
@property (weak, nonatomic) IBOutlet UILabel *detailDevName;
@property (weak, nonatomic) IBOutlet UILabel *detailStars;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailDescriptionTextView;


@end
