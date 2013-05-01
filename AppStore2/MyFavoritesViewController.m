//
//  MyFavoritesViewController.m
//  AppStore2
//
//  Created by yueling zhang on 4/28/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import "MyFavoritesViewController.h"
#import "MyCustomCollectionViewCell.h"
#import "DataSingleton.h"
#import "Application.h"
#import "Artist.h"

@interface MyFavoritesViewController ()
@end

@implementation MyFavoritesViewController

@synthesize fetchedResultsController,managedObjectContext,favCollectionView,favList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    managedObjectContext = [[DataSingleton sharedInstance] managedObjectContext];
    
    [favCollectionView setDataSource:self];
    [favCollectionView setDelegate:self];
    [self fetchFromCoreData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchFromCoreData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - fetch data method
/*******************************************************************************
 * @method          fetch data method
 * @abstract
 * @description     fetch from core data
 ******************************************************************************/
- (void)fetchFromCoreData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Application" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    favList = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [favCollectionView reloadData];
}

#pragma mark - Font method 
/*******************************************************************************
 * @method          change font using NSMutableAttributedString
 * @abstract
 * @description
 ******************************************************************************/
- (NSMutableAttributedString *)changeFont:(NSString *)strLabel
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:strLabel];
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[UIColor grayColor]];
    [shadow setShadowOffset:CGSizeMake(0, 3)];
    
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, attrString.length)];
    
    return attrString;
}

#pragma mark - Fetched results controller Delegate
/*******************************************************************************
 * @method          fetchedResultsController
 * @abstract
 * @description
 ******************************************************************************/
- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    } else {
        //Create and configure a fetch request with entities.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Application"];
        
        // Create the sort descriptors array.
        NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist.artistName" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:authorDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        //Create and initialize the fetch results controller.
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"artist.artistName" cacheName:nil];
        fetchedResultsController.delegate = self;

        return fetchedResultsController;
    }
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [favList count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Returning cell %@", indexPath);
    MyCustomCollectionViewCell *myCustomCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"favCell" forIndexPath: indexPath];
    
    if ([favList count] == 0) {
        return myCustomCell;
    }else{
        Application *app = [favList objectAtIndex:indexPath.row];
        
        myCustomCell.favAppName.text = app.trackName;
        myCustomCell.favDevName.text = app.artist.artistName;
        myCustomCell.favStars.text = app.appStars;
        myCustomCell.favDescripTextView.text = app.appDescrip;
        
        NSString *theDescriptionLabel = @"Description: ";
        myCustomCell.favDescription.attributedText = [self changeFont:theDescriptionLabel];
        
        NSURL *iconURL = [[NSURL alloc] initWithString:app.iconData];
        NSData *iconURLData = [[NSData alloc] initWithContentsOfURL:iconURL];
        myCustomCell.favIconImageView.image = [UIImage imageWithData:iconURLData];
        
        return myCustomCell;
    }
}

@end
