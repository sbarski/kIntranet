//
//  LoginViewController.h
//  kIntranet
//
//  Created by Peter Sbarski on 14/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>
-(BOOL)loginToKIntranet : (LoginViewController *)controller currentUserid : (NSString*)authenticatedUserId currentFirstName: (NSString*)authenticatedFirstName currentLastName:(NSString *)authenticatedLastName;
@end

@interface LoginViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIButton *loginButton;
    IBOutlet UIActivityIndicatorView *loginIndicator;
}

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIActivityIndicatorView *loginIndicator;

@property (nonatomic, strong) id <LoginViewControllerDelegate> delegate;

-(IBAction)viewTouchUpInside:(id)sender;

-(IBAction) login: (id) sender;

@end
