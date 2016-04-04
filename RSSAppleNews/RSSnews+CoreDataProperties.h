//
//  RSSnews+CoreDataProperties.h
//  RSSAppleNews
//
//  Created by ed8009 on 24.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "RSSnews.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSSnews (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *nameRSS;
@property (nullable, nonatomic, retain) NSString *linkRSS;
@property (nullable, nonatomic, retain) NSSet<RSSDetails *> *details;

@end

@interface RSSnews (CoreDataGeneratedAccessors)

- (void)addDetailsObject:(RSSDetails *)value;
- (void)removeDetailsObject:(RSSDetails *)value;
- (void)addDetails:(NSSet<RSSDetails *> *)values;
- (void)removeDetails:(NSSet<RSSDetails *> *)values;

@end

NS_ASSUME_NONNULL_END
