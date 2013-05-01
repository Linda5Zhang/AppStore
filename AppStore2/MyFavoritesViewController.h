//
//  MyFavoritesViewController.h
//  AppStore2
//
//  Created by yueling zhang on 4/28/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyFavoritesViewController : UIViewController<NSFetchedResultsControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *favList;

@property (weak, nonatomic) IBOutlet UICollectionView *favCollectionView;

@end
