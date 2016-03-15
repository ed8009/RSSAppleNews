//
//  NewsRSS.h
//  RSSAppleNews
//
//  Created by ed8009 on 10.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NewsRSS : NSManagedObject

@property (nullable, nonatomic, retain) NSDate *newsDate;
@property (nullable, nonatomic, retain) NSString *newsDescription;
@property (nullable, nonatomic, retain) NSString *newsLink;
@property (nullable, nonatomic, retain) NSString *newsTitle;

@end


