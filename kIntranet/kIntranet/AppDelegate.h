//
//  AppDelegate.h
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESTClient.h"

#import "Staff.h"
#import "StaffViewController.h"
#import "LoginViewController.h"
#import "MyViewController.h"

@class AppDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate, LoginViewControllerDelegate, RESTClientDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) BOOL isAuthenticated;

@end
