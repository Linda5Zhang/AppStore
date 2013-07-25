//
//  Application.h
//  AppStore2
//
//  Created by yueling zhang on 4/29/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist;

@interface Application : NSManagedObject

@property (nonatomic, retain) NSString * iconData;
@property (nonatomic, retain) NSString * trackName;
@property (nonatomic, retain) NSString * appStars;
@property (nonatomic, retain) NSString * appDescrip;
@property (nonatomic, retain) Artist *artist;

@end
