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

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    employees = [NSMutableArray arrayWithCapacity:100];
    
    self.isAuthenticated = false;
    
    Staff *staff = [[Staff alloc] init];
    staff.name = @"Peter Sbarski";
    staff.location = @"Melbourne Office";
    staff.checkin = nil;
    staff.checkout = nil;
    
    [employees addObject:staff];
    
    staff = [[Staff alloc] init];
    staff.name = @"Sam Kroonenburg";
    staff.location = @"TechEd";
    staff.checkout = [self getCurrentDate:0];
    staff.checkin = [self getCurrentDate:10];
    
    [employees addObject:staff];
    
    UITabBarController *tabBarController = (UITabBarController *) self.window.rootViewController;
    
    UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
    
    StaffViewController *staffViewController = [[navigationController viewControllers] objectAtIndex:0];
    staffViewController.employees = employees;
    
    //try automatic sign in
    [self automaticUserLoginSuccess];
          
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
    if ([self authenticateUser:username password:password])
    {
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
        
        [keychainItem setObject:username forKey:kSecAttrAccount];
        
        [keychainItem setObject:password forKey:kSecValueData];
        
        self.isAuthenticated = true;
        
        return true;
    }
    
    return false;
}

-(BOOL)automaticUserLoginSuccess
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
    
    NSString *username = [keychainItem objectForKey:kSecAttrAccount];
    NSString *password = [keychainItem objectForKey:kSecValueData];
    
    if (username == nil || [username isEqualToString:@""])
    {
        return NO;
    }
    
    if (password == nil || [password isEqualToString:@""])
    {
        return NO;
    }

    [keychainItem release];

    BOOL isAuthenticationSuccessful = [self authenticateUser:username password:password];
    
    self.isAuthenticated = isAuthenticationSuccessful;
    
    return isAuthenticationSuccessful;
}

-(BOOL)logoutUser
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
    
    [keychainItem resetKeychainItem];
    
    [keychainItem release];
    
    return true;
}


-(void)loadStaffList
{
    NSURL *url = [NSURL URLWithString:@"http://transit.local/api/account/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"IP Address: %@", [JSON valueForKey:@"origin"]);
    } failure:nil];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSArray *trustedHosts = [NSArray arrayWithObjects:@"transit.local",nil];
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if ([trustedHosts containsObject:challenge.protectionSpace.host]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    
    if (statusCode == 200)
    {
        NSString *url = [[response URL] absoluteString];
        [url release];
    }
    
    if (statusCode >= 400) {
        // do error handling here
        NSLog(@"remote url returned error %d %@",statusCode,[NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
    } else {
        // start recieving data
    }
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString *mydata=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *e;
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [mydata dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &e];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    //[self handleData]; // Deal with the data
}

-(BOOL)authenticateUser:(NSString *)username password:(NSString*)password
{
    username = @"Email";
    password = @"password";
    
    NSString *post = [NSString stringWithFormat:@"Email=%@&Password=%@", username, password];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]init]autorelease];
    
    [request setURL:[NSURL URLWithString:@"https://transit.local/api/account/logon"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSURLResponse *response;
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
                    
    /*
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    
    NSError *e;
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [data dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &e];
    */
    [conn release];
    
    //NSLog(data);
   
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
