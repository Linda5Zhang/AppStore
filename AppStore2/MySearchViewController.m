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
@property int flag;
@end

@implementation MySearchViewController
{
    NSString *searchData;
    NSCache *previousCachedData;
    NSMutableArray *gotDataOnline;
    NSMutableArray *gotFromCachedData;
    NSArray *showAsArtist;
    NSArray *showAsPrice;
    NSArray *showAsRating;
    NSArray *showedData;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    previousCachedData = [[NSCache alloc] init];
    
    [myCollectionView setDataSource:self];
    [myCollectionView setDelegate:self];

    UIBarButtonItem *artistButton = [[UIBarButtonItem alloc] initWithTitle:@"Artist" style:UIBarButtonItemStyleBordered target:self action:@selector(sortByArtist)];
    UIBarButtonItem *priceButton = [[UIBarButtonItem alloc] initWithTitle:@"Price" style:UIBarButtonItemStyleBordered target:self action:@selector(sortByPrice)];
    UIBarButtonItem *ratingButton = [[UIBarButtonItem alloc] initWithTitle:@"Rating" style:UIBarButtonItemStyleBordered target:self action:@selector(sortByRating)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:artistButton, priceButton, ratingButton, nil];
    

    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    myLabel.text = @"Search By :";
    UIView *labelView = myLabel;
    labelView.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *searchByButton = [[UIBarButtonItem alloc] initWithCustomView:labelView];
    self.navigationItem.leftBarButtonItem = searchByButton;
    
    dmvc = [[DetailModelViewController alloc] init];
    
}

# pragma mark - Search by different mata data
- (void)sortByArtist
{
    [mySearchBar resignFirstResponder];
    self.flag = 3;
    [self callSearch];
}

- (void)sortByPrice
{
    [mySearchBar resignFirstResponder];
    self.flag = 2;
    [self callSearch];
}

- (void)sortByRating
{
    [mySearchBar resignFirstResponder];
    self.flag = 1;
    [self callSearch];
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
//            NSLog(@"Got the data from itune api, and store in an NSMutable Array called: gotDatOnline ");
//            NSLog(@"show got data from on line : %@",gotDataOnline);
            
            //also store the results to 'previousCachedData' NSCache
            //remember that user has already searched the data before
            [previousCachedData setObject:gotDataOnline forKey:@"PreviousData"];
//            NSLog(@"stored previous searched data in NSCache");
//            NSLog(@"show previous searched data in NSCahe: %@",previousCachedData);
            
            if (self.flag == 1) {//Sort by average rating
                NSSortDescriptor *ratingDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageUserRating" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:ratingDescriptor];
                showAsRating = [[NSArray alloc] initWithArray:[gotDataOnline sortedArrayUsingDescriptors:sortDescriptors]];
                NSLog(@"show the sorted array by rating: %@",showAsRating);
                showedData = [[NSArray alloc]initWithArray:showAsRating];
                
            }else if(self.flag == 2){//Sort by price
                NSSortDescriptor *priceDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:priceDescriptor];
                showAsPrice = [[NSArray alloc] initWithArray:[gotDataOnline sortedArrayUsingDescriptors:sortDescriptors]];
                NSLog(@"show the sorted array by price: %@",showAsPrice);
                showedData = [[NSArray alloc]initWithArray:showAsPrice];
                
            }else if(self.flag == 3){//Sort by artist name
                NSSortDescriptor *artistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artistName" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:artistDescriptor];
                showAsArtist = [[NSArray alloc] initWithArray:[gotDataOnline sortedArrayUsingDescriptors:sortDescriptors]];
                NSLog(@"show the sorted array by artist name : %@",showAsArtist);
                showedData = [[NSArray alloc]initWithArray:showAsArtist];
                
            }else{//Default sorting
                showedData = gotDataOnline;
            }

            [myCollectionView reloadData];
   
        }
    }];
    
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
        
//        NSLog(@"Previous searched data are stored in NSCache : ");
//        NSLog(@"Show previous searched data : %@",gotFromCachedData);
        
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
            showedData = gotFromCachedData;
            [myCollectionView reloadData];
         
        }else{
            [self downloadData:searchData];
        }
        
    }
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
    return [showedData count];
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
        NSLog(@"Collection View :: showed data : %@",showedData);
        
        myCustomCell.appNameLabel.text = [[showedData objectAtIndex:indexPath.row] objectForKey:@"trackName"];
        myCustomCell.developerNameLabel.text = [[showedData objectAtIndex:indexPath.row] objectForKey:@"artistName"];
        NSNumber *starNum = [[showedData objectAtIndex:indexPath.row] objectForKey:@"averageUserRating"];
        myCustomCell.starsLabel.text = [starNum stringValue];
        myCustomCell.genresLabel.text = [[showedData objectAtIndex:indexPath.row] objectForKey:@"primaryGenreName"];
        myCustomCell.priceLabel.text = [[showedData objectAtIndex:indexPath.row] objectForKey:@"formattedPrice"];
        
        NSString *strIconURL = [[showedData objectAtIndex:indexPath.row] objectForKey:@"artworkUrl60"];
        NSURL *iconURL = [[NSURL alloc] initWithString:strIconURL];
        NSData *iconURLData = [[NSData alloc] initWithContentsOfURL:iconURL];
        myCustomCell.iconImageView.image = [UIImage imageWithData:iconURLData];
        
        NSMutableArray *arrayScreenShotURL = [[showedData objectAtIndex:indexPath.row] objectForKey:@"screenshotUrls"];
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
        NSDictionary *theSelected = [showedData objectAtIndex:indexpath.row];
        
        dmvc= [segue destinationViewController];
        dmvc.currentAppDetail = theSelected;
        
    }
    
}


@end
