//
//  BrowserViewController.h
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *url;

@end
