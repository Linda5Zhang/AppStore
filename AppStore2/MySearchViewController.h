//
//  MySearchViewController.h
//  AppStore2
//
//  Created by yueling zhang on 4/26/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySearchViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UISearchBarDelegate>

@property Boolean isFiltered;
@property Boolean isRelatedAndArtist;

@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
- (IBAction)searchByArtistButton:(id)sender;

@end
