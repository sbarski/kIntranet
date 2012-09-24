//
//  StaffViewController.h
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Staff.h"
#import "CheckoutViewController.h"
#import "LoginViewController.h"

#import "RESTClientKIntranet.h"

@interface StaffViewController : UITableViewController<CheckoutViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *employees; //mutable array property
@property (nonatomic, strong) NSArray *selectedCells;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *userid;

- (IBAction)checkInStaff:(id)sender;

@end
