//
//  LoadingData.h
//  RSSAppleNews
//
//  Created by ed8009 on 14.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingData : UIViewController

@property (nonatomic) NSMutableData *rssData;

- (void)startConnction:(NSURL *)url;

+ (id)sharedMyManagerLoading;

@end
