//
//  CheckoutViewController.h
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Staff.h"

@class CheckoutViewController;

@protocol CheckoutViewControllerDelegate <NSObject>
-(void)checkoutViewControllerDidCancel : (CheckoutViewController *)controller;
-(void)checkoutViewControllerDidSave : (CheckoutViewController *)controller;
-(NSArray*)selectedStaff : (CheckoutViewController *)controller;
@end

@interface CheckoutViewController : UITableViewController

@property (nonatomic, strong) id <CheckoutViewControllerDelegate> delegate;
- (IBAction)cancel: (id)sender;
- (IBAction)done: (id)sender;
@end
