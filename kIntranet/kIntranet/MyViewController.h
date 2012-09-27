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

@interface OptionSwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch* switchControl;
@end

@interface MyViewController : UITableViewController<LoginViewControllerDelegate>

@end
