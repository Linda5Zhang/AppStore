//
//  DetailModelViewController.m
//  AppStore2
//
//  Created by yueling zhang on 4/28/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import "DetailModelViewController.h"
#import "MyCustomCollectionViewCell.h"
#import "MySearchViewController.h"
#import "DataSingleton.h"
#import "Application.h"
#import "Artist.h"

@interface DetailModelViewController ()
 
@end

@implementation DetailModelViewController
{
    NSString *theAppName;
    NSString *theDevName;
    NSNumber *theStars;
    NSString *theDescription;
    NSString *theStrIconURL;
    NSArray *checkFavList;
}

@synthesize currentAppDetail,managedObjectContext,fetchedResultsController,detailCollectionView;

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
    
    [detailCollectionView setDataSource:self];
    [detailCollectionView setDelegate:self];
    
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated
{
    managedObjectContext = [[DataSingleton sharedInstance] managedObjectContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - get data method
- (void)getData
{
    NSLog(@"current app detail : %@",currentAppDetail);
    theAppName = [currentAppDetail objectForKey:@"trackName"];
    theDevName = [currentAppDetail objectForKey:@"artistName"];
    theStars = [currentAppDetail objectForKey:@"averageUserRating"];
    theDescription = [currentAppDetail objectForKey:@"description"];
    theStrIconURL = [currentAppDetail objectForKey:@"artworkUrl60"];
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

#pragma mark - action methods
/*******************************************************************************
 * @method          click buy button method
 * @abstract
 * @description
 ******************************************************************************/
- (IBAction)buyButton:(id)sender
{
    NSString *strAppStoreURL = [currentAppDetail objectForKey:@"artistViewUrl"];
    NSLog(@"the app store url is : %@",[strAppStoreURL substringWithRange:NSMakeRange(0, strAppStoreURL.length-9)]);
    NSURL *AppStoreURL = [[NSURL alloc] initWithString:strAppStoreURL];
    
    [[UIApplication sharedApplication] openURL: AppStoreURL];
}

/*******************************************************************************
 * @method          click fav button method
 * @abstract
 * @description
 ******************************************************************************/
- (IBAction)favButton:(id)sender
{    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Application" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"trackName == %@",theAppName];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"trackName", nil];
    
    NSError *error;
    checkFavList = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"check  favList : %@",checkFavList);
    
    //Check whether is already in favorite list
    if (checkFavList.count == 0) {
        [[DataSingleton sharedInstance] addApplication:theAppName fromArtist:theDevName withStars:theStars withDescription:theDescription withIconImagesURL:theStrIconURL];
        NSLog(@"Did add to Fav List!");
    } else {
        UIAlertView *SuccessfulAlert = [[UIAlertView alloc] initWithTitle:@"Already Added!" message:@"You have added the app to your favorite list!" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [SuccessfulAlert show];
    }
      
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCustomCollectionViewCell *myCustomCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailCell" forIndexPath: indexPath];
        
    myCustomCell.detailAppName.text = theAppName;
    myCustomCell.detailDevName.text = theDevName;
    NSNumber *starNum = theStars;
    myCustomCell.detailStars.text = [starNum stringValue];
    myCustomCell.detailDescriptionTextView.text = theDescription;
    
    NSString *theDescriptionLabel = @"Description: ";
    myCustomCell.detailDescriptionLabel.attributedText = [self changeFont:theDescriptionLabel];
        
    NSString *strIconURL = theStrIconURL;
    NSURL *iconURL = [[NSURL alloc] initWithString:strIconURL];
    NSData *iconURLData = [[NSData alloc] initWithContentsOfURL:iconURL];
    myCustomCell.detailIconImageView.image = [UIImage imageWithData:iconURLData];
        
    return myCustomCell;
    
}

@end
