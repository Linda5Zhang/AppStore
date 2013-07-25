//
//  Artist.h
//  AppStore2
//
//  Created by yueling zhang on 4/29/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Application;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSSet *applications;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addApplicationsObject:(Application *)value;
- (void)removeApplicationsObject:(Application *)value;
- (void)addApplications:(NSSet *)values;
- (void)removeApplications:(NSSet *)values;

@end
