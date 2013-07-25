//
//  DetailModelViewController.h
//  AppStore2
//
//  Created by yueling zhang on 4/28/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailModelViewController : UIViewController<NSFetchedResultsControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>


@property (strong, nonatomic) NSDictionary *currentAppDetail;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@property (weak, nonatomic) IBOutlet UICollectionView *detailCollectionView;


- (IBAction)buyButton:(id)sender;
- (IBAction)favButton:(id)sender;

@end
