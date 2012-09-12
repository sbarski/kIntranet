//
//  StaffViewController.h
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Staff.h"
#import "CheckoutViewController.h"

@interface StaffViewController : UITableViewController<CheckoutViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *employees; //mutable array property
@property (nonatomic, strong) NSArray *selectedCells;

@end
