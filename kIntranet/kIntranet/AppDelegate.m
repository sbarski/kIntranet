		//
//  AppDelegate.m
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    NSMutableArray *employees;
}

@synthesize isAuthenticated;
@synthesize loginViewController;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    employees = [NSMutableArray arrayWithCapacity:100];

    UITabBarController *tabBarController = (UITabBarController *) self.window.rootViewController;
    
    UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
    
    StaffViewController *staffViewController = [[navigationController viewControllers] objectAtIndex:0];
    staffViewController.employees = employees;
    
    self.isAuthenticated = FALSE;
    
    //try automatic sign in
    [self loginToIntranet];
          
    return YES;
}

- (NSDate*) getCurrentDate:(NSInteger)hours
{
    NSDate *currentDate = [NSDate date];
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:hours];
    NSDate *date = [gregorian dateByAddingComponents:comps toDate:currentDate options:0];
    [comps release];
    
    return date;
}


-(BOOL)manualUserLogin:(LoginViewController *)controller username:(NSString *)username password:(NSString *)password
{
    RESTClient *restClient = [[RESTClient alloc]init];
    restClient.delegate = self;
    
    self.loginViewController = controller;
    
    [restClient authenticateUserBy:username andPassword:password];
    
    return true;
}

-(BOOL)loginToIntranet
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
    
    NSString *token = [keychainItem objectForKey:kSecValueData];
    
    if (token == nil || [token isEqualToString:@""])
    {
        return NO;
    }

    [keychainItem release];
    
    self.isAuthenticated = true;
    
    return YES;
}

-(void)authenticateUser:(BOOL)success and:(NSString*)token
{
    if (success == TRUE)
    {
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
        
        //store token
        [keychainItem setObject:token forKey:kSecValueData];
        
        self.isAuthenticated = true;
        
        UITabBarController *tabBarController = (UITabBarController *) self.window.rootViewController;
        UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
        StaffViewController *staffViewController = [[navigationController viewControllers] objectAtIndex:0];
        [staffViewController refreshStaffList];
    }

    [loginViewController userAuthenticationCompleted:success];
}

-(BOOL)logoutUser
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
    
    [keychainItem resetKeychainItem];
    
    [keychainItem release];
    
    return true;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
