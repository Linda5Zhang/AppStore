//
//  MySearchViewController.m
//  AppStore2
//
//  Created by yueling zhang on 4/26/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import "MySearchViewController.h"
#import "GTMHTTPFetcher.h"
#import "MyCustomCollectionViewCell.h"
#import "DetailModelViewController.h"

@interface MySearchViewController ()
@end

@implementation MySearchViewController
{
    NSString *searchData;
    NSCache *previousCachedData;
    NSMutableArray *gotDataOnline;
    NSMutableArray *gotFromCachedData;
    NSMutableArray *showAsRelated;
    NSMutableArray *sortedDataOne;
    NSMutableArray *sortedDataTwo;
    NSMutableArray *unSortedData;
    DetailModelViewController *dmvc;
}

@synthesize mySearchBar,myCollectionView,isFiltered,isRelatedAndArtist;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    previousCachedData = [[NSCache alloc] init];
    
    [myCollectionView setDataSource:self];
    [myCollectionView setDelegate:self];
    
    dmvc = [[DetailModelViewController alloc] init];
    
}

# pragma mark - download data method
/*******************************************************************************
 * @method          downloadData
 * @abstract        if the search data is not in nscache
 * @description     download data using itune search api
 ******************************************************************************/
- (void)downloadData:(NSString *)searchContent
{
    NSString *apiURL1 = @"https://itunes.apple.com/search?term=";
    NSString *apiURL2 = searchContent;
    NSString *apiURL3 = @"&country=us&entity=software";
    NSString *apiURL = [[apiURL1 stringByAppendingString:apiURL2] stringByAppendingString:apiURL3];
    NSLog(@"api url is : %@",apiURL);
    
    NSURL *url = [NSURL URLWithString:apiURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //using GRMHTTPFetcher to to communicate with itune search api
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrivedData, NSError *error) {
        if (error != nil) {
            // Log error
            NSLog(@"ERROR:%@",error);
        }else{
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:retrivedData options:kNilOptions error:&error];
            
            //store the results to a NSMutableArray 'gotDataOnline'
            gotDataOnline = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            NSLog(@"Got the data from itune api, and store in an NSMutable Array called: gotDatOnline ");
            NSLog(@"show got data from on line : %@",gotDataOnline);
            
            //also store the results to 'previousCachedData' NSCache
            //remember that user has already searched the data before
            [previousCachedData setObject:gotDataOnline forKey:@"PreviousData"];
            NSLog(@"stored previous searched data in NSCache");
            NSLog(@"show previous searched data in NSCahe: %@",previousCachedData);

            //determine how to sort the data and show it
            if (isRelatedAndArtist != FALSE) {
                //show it according to related and artistName
                [self searchByRelatedAndArtistName];
            } else {
                //just show it as default 
                showAsRelated = [[NSMutableArray alloc] init];
                showAsRelated = gotDataOnline;
            }
            
            NSLog(@"show related data : %@",showAsRelated);
            [myCollectionView reloadData];
        }
    }];
    
}

# pragma mark - sort by related&artiest name (in ascending order) method
/*******************************************************************************
 * @method          sort the data by related and artistname
 * @abstract        
 * @description     sort the default data by two rules.
 *                  First:A user search 'yelp', he/she wants to see the yelp app
 *                        in the first place, then wants to see related apps 
 *                  Second:If the results' app names are not very related to 
 *                         the user searched app name, then sort by artist name
 *                          (in the ascendering order)
 ******************************************************************************/
- (void)searchByRelatedAndArtistName
{
    showAsRelated = [[NSMutableArray alloc] init];
    sortedDataOne = [[NSMutableArray alloc] init];
    sortedDataTwo = [[NSMutableArray alloc] init];
    unSortedData = [[NSMutableArray alloc] init];
   
    for (int i = 0; i < gotDataOnline.count; i++) {
        
        NSString *gotAppName = [[gotDataOnline objectAtIndex:i] objectForKey:@"trackName"];
        NSString *gotAppNameNoSpace = [gotAppName stringByReplacingOccurrencesOfString:@" "  withString:@""];
        NSString *gotSubAppName = [gotAppNameNoSpace substringWithRange:NSMakeRange(0, gotAppName.length/2)];
        NSString *gotAppNameFirst = [gotAppName componentsSeparatedByString:@" "][0];
        NSString *searchSubAppName = [searchData substringWithRange:NSMakeRange(0,searchData.length/2)];
        
        if ([gotAppNameNoSpace caseInsensitiveCompare: searchData] == NSOrderedSame) {
            [sortedDataOne addObject:[gotDataOnline objectAtIndex:i]];
            NSLog(@"sorted data one array is : %@",sortedDataOne);
        } else if (([gotAppNameFirst caseInsensitiveCompare:searchSubAppName] == NSOrderedSame) || ([gotSubAppName caseInsensitiveCompare: searchSubAppName] == NSOrderedSame)) {
            [sortedDataTwo addObject:[gotDataOnline objectAtIndex:i]];
        } else {
            [unSortedData addObject:[gotDataOnline objectAtIndex:i]];
        }
    }
    
    NSLog(@"the unsorted data array is : %@",unSortedData);

    //sort as developer name in ascendering order
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artistName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [unSortedData sortUsingDescriptors:sortDescriptors];
    NSLog(@"sorted Data one is : %@",unSortedData);
    
    //First add the related results,
    //then add the not very related results by sorting artist name
    [showAsRelated addObjectsFromArray:sortedDataOne];
    [showAsRelated addObjectsFromArray:sortedDataTwo];
    [showAsRelated addObjectsFromArray:unSortedData];
    NSLog(@"show related&artistname  data : %@",showAsRelated);
    
    [myCollectionView reloadData];
}

# pragma mark - search method
/*******************************************************************************
 * @method          search method
 * @abstract        
 * @description     when a user click the button to search, determine whether
 *                  is stored in NSCache(previous searched data) or not
 ******************************************************************************/
- (void)callSearch
{
    //get from NSCache
    gotFromCachedData = [previousCachedData objectForKey:@"PreviousData"];
    
    if (gotFromCachedData == NULL) {
        [self downloadData:searchData];
    } else {
        
        NSLog(@"Previous searched data are stored in NSCache : ");
        NSLog(@"Show previous searched data : %@",gotFromCachedData);
        
        int num = [gotFromCachedData count];
        NSLog(@"countNum is %d",num);
        
        NSString *previousSearchedString = NULL;
        Boolean *isCached = FALSE;
        for (int i = 0; i < num; i++) {
            previousSearchedString = [[gotFromCachedData objectAtIndex:i] objectForKey:@"trackName"];
            
            if ([previousSearchedString caseInsensitiveCompare:searchData] == NSOrderedSame) {
                break;
            }
        }
        if (isCached != FALSE) {
            showAsRelated = gotFromCachedData;
            [myCollectionView reloadData];
        }else{
            [self downloadData:searchData];
        }
        
    }
}

/*******************************************************************************
 * @method          search by related and artist name (in ascending order)
 * @abstract        click the 'Related&Artist Name' button, call this method
 * @description
 ******************************************************************************/
- (IBAction)searchByArtistButton:(id)sender {
    [mySearchBar resignFirstResponder];
    isRelatedAndArtist = TRUE;
    [self callSearch];
}

#pragma mark - UISearchBar Delegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        isFiltered = NO;
    }else{
        isFiltered = YES;
        searchData = searchText;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [mySearchBar resignFirstResponder];
    [self callSearch];
    
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [showAsRelated count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Returning cell %@", indexPath);
    MyCustomCollectionViewCell *myCustomCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"appCell" forIndexPath: indexPath];
    if (isFiltered == NO) {
        
        return myCustomCell;
    } else {
        NSLog(@"Collection View :: show related data : %@",showAsRelated);
        
        myCustomCell.appNameLabel.text = [[showAsRelated objectAtIndex:indexPath.row] objectForKey:@"trackName"];
        myCustomCell.developerNameLabel.text = [[showAsRelated objectAtIndex:indexPath.row] objectForKey:@"artistName"];
        NSNumber *starNum = [[showAsRelated objectAtIndex:indexPath.row] objectForKey:@"averageUserRating"];
        myCustomCell.starsLabel.text = [starNum stringValue];
        myCustomCell.genresLabel.text = [[showAsRelated objectAtIndex:indexPath.row] objectForKey:@"primaryGenreName"];
        myCustomCell.priceLabel.text = [[showAsRelated objectAtIndex:indexPath.row] objectForKey:@"formattedPrice"];
        
        NSString *strIconURL = [[showAsRelated objectAtIndex:indexPath.row] objectForKey:@"artworkUrl60"];
        NSURL *iconURL = [[NSURL alloc] initWithString:strIconURL];
        NSData *iconURLData = [[NSData alloc] initWithContentsOfURL:iconURL];
        myCustomCell.iconImageView.image = [UIImage imageWithData:iconURLData];
        
        NSMutableArray *arrayScreenShotURL = [[showAsRelated objectAtIndex:indexPath.row] objectForKey:@"screenshotUrls"];
        NSString *strScreenShotURL = arrayScreenShotURL[0];
        NSURL *screenShotURL = [[NSURL alloc] initWithString:strScreenShotURL];
        NSData *screenShotURLData = [[NSData alloc] initWithContentsOfURL:screenShotURL];
        myCustomCell.screenShotImageView.image = [UIImage imageWithData:screenShotURLData];
        
        return myCustomCell;
    }

}
 
# pragma mark - Segue
/*******************************************************************************
 * @method          prepareForSegue:sender
 * @abstract        Call before the segue
 * @description     Pass the detail data
 ******************************************************************************/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue to detail...");
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexpath = [[myCollectionView indexPathsForSelectedItems] lastObject];
        NSDictionary *theSelected = [showAsRelated objectAtIndex:indexpath.row];
        
        dmvc= [segue destinationViewController];
        dmvc.currentAppDetail = theSelected;
        
    }
    
}


@end
