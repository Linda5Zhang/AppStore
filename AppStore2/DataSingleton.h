//
//  DataSingleton.h
//  AppStore2
//
//  Created by yueling zhang on 4/28/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSingleton : NSObject


// The applications core data context
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Methods
+ (id)sharedInstance;

- (void)addApplication:(NSString *)application fromArtist:(NSString *)artist withStars:(NSNumber *)stars withDescription:(NSString *)description withIconImagesURL:(NSString *)iconImageURL;


@end
