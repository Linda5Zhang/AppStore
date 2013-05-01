//
//  DataSingleton.m
//  AppStore2
//
//  Created by yueling zhang on 4/28/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import "DataSingleton.h"
#import "Application.h"
#import "Artist.h"

@implementation DataSingleton

@synthesize managedObjectContext;

/*******************************************************************************
 * @method          sharedInstance
 * @abstract        Create the singleton
 * @description     Not sure about the block stuff, but it works
 ******************************************************************************/
+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
    
}

/*************************************************************************************
 * @method          addApplication:fromArtist:withStars:withDescription:withIconImage
 * @abstract        Add data to core data store
 * @description     <# Description #>
 ************************************************************************************/
- (void)addApplication:(NSString *)application fromArtist:(NSString *)artist withStars:(NSNumber *)stars withDescription:(NSString *)description withIconImagesURL:(NSString *)iconImageURL
{
    NSLog(@"Adding %@",artist);
    //Create a new instance of Application object
    Application *app = (Application *)[NSEntityDescription insertNewObjectForEntityForName:@"Application" inManagedObjectContext:managedObjectContext];
    
    app.trackName = application;
    app.appDescrip = description;
    app.appStars = [stars stringValue];
    app.iconData = iconImageURL;
    
    //Create a new Artist object (if needed)
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"artistName == %@",artist];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"artistName", nil];
    
    NSArray *fetchedItems = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Artist *art;
    if (fetchedItems.count == 0) {
        art = (Artist *)[NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:managedObjectContext];
        art.artistName = artist;
        app.artist = art;
    } else {
        app.artist = [fetchedItems lastObject];
    }
    
    //Commit the change to on-disk store
    if (![managedObjectContext save:&error]) {
        //Handle the error.
    }
    NSLog(@"core data-- app data are : %@",app);
    NSLog(@"core data-- artist data are : %@",art);
}

#pragma mark - Setup
/*******************************************************************************
 * @method      init
 * @abstract    Overwrite the init method to get the date and set the user defaults
 * @description <# description #>
 *******************************************************************************/
- (id)init
{
    if (self = [super init]) {
        // do extra init here
        
    
    }
    return self;
}


@end
