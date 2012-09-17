//
//  LoginViewController.m
//  kIntranet
//
//  Created by Peter Sbarski on 14/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameField;
@synthesize passwordField;

@synthesize loginButton;
@synthesize loginIndicator;

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.loginIndicator.hidden = YES;
    self.passwordField.delegate = self;
    self.usernameField.delegate = self;
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setPasswordField:nil];
    [self setUsernameField:nil];
        
    [super viewDidUnload];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameField)
    {
        [passwordField becomeFirstResponder];
    }
    
    if (textField == passwordField)
    {
        [self.passwordField resignFirstResponder];
        [self login:self];
    }
    return YES;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp keyboardSize:(CGSize)keyboard
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= keyboard.height;
        rect.size.height += keyboard.height;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += keyboard.height;
        rect.size.height -= keyboard.height;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


-(void)keyboardWillShow:(NSNotification*) notification {
    // Animate the current view out of the way
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES keyboardSize:kbSize];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO keyboardSize:kbSize];
    }
}
 

-(void)keyboardWillHide:(NSNotification*) notification {
    // Animate the current view out of the way
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES keyboardSize:kbSize];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO keyboardSize:kbSize];
    }
}

- (IBAction)viewTouchUpInside:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (IBAction) login: (id) sender
{
    //TODO: spawn a login thread
    if ([self.passwordField.text length] > 0 && [self.usernameField.text length] > 0)
    {
        [usernameField resignFirstResponder];
        [passwordField resignFirstResponder];
        
        self.loginIndicator.hidden = FALSE;
        
        [loginIndicator startAnimating];
    
        self.loginButton.enabled = FALSE;
                
        if ([self.delegate manualUserLogin:self username:self.usernameField.text password:self.passwordField.text])
        {
            [self dismissModalViewControllerAnimated:YES];
        }
        else
        {
            self.loginIndicator.hidden = TRUE;
            
            [loginIndicator stopAnimating];
            
            self.loginButton.enabled = TRUE;
            
            self.passwordField.text = @"";
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Could not login" message:@"kIntranet could not login. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Login Incomplete" message:@"You must enter a username and password to login" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [super dealloc];
}
@end
