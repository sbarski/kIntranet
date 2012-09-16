//
//  MyViewController.h
//  kIntranet
//
//  Created by Peter Sbarski on 16/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class MyViewController;

@protocol MyViewControllerDelegate <NSObject>
-(void)logoutUser : (MyViewController *)controller;
@end

@interface MyViewController : UITableViewController<LoginViewControllerDelegate>

@property (nonatomic, strong) id <MyViewControllerDelegate> delegate;

@end
