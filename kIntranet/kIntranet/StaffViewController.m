//
//  StaffViewController.m
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "StaffViewController.h"

@interface StaffViewController ()

@end

@implementation StaffViewController

@synthesize employees;
@synthesize selectedCells;

@synthesize firstName;
@synthesize lastName;
@synthesize userid;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    [self tableView].allowsMultipleSelection = TRUE;
    
    [self performSelector:@selector(handleLogin) withObject:nil afterDelay:0];
   
}

-(void)updateStaffList:(NSDictionary *)list
{
    [employees removeAllObjects];

    //[dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
    
    for (NSDictionary *key in list)
    {
        Staff *staff = [[Staff alloc] init];
        staff.name = [[[key objectForKey:@"Firstname"] stringByAppendingString:@" "] stringByAppendingString:[key objectForKey:@"Lastname"]];
        staff.location = [key objectForKey:@"Location"];
        
        if ([key objectForKey:@"In"] == [NSNull null])
        {
            staff.checkin = nil;
        }
        else
        {
            staff.checkin = [StaffViewController dateFromInternetDateTimeString:[key objectForKey:@"In"]];
        }
        
        staff.checkout = [key objectForKey:@"Out"] == [NSNull null] ? nil : [StaffViewController dateFromInternetDateTimeString:[key objectForKey:@"Out"]];
        
        staff.identification = [key objectForKey:@"Id"];
        
        [employees addObject:staff];
    }
    
    [self.tableView reloadData];
}

-(void)userSignOut
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    appDelegate.isAuthenticated = FALSE;
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"kIntranet" message:@"You have been signed out. Please log-in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    
    [self handleLogin];
}

-(void)refreshStaffList
{
    RESTClientKIntranet *client = [[[RESTClientKIntranet alloc]init]autorelease];
    
    client.delegate = self;
    
    [client refreshStaffList];
}

-(void)handleLogin
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (!appDelegate.isAuthenticated)
    {
        UIStoryboard *storyboard = [UIApplication sharedApplication].delegate.window.rootViewController.storyboard;
        
        LoginViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
        
        loginController.delegate = appDelegate;
        
        [self presentModalViewController:loginController animated:YES];
    }
    else
    {
        RESTClientKIntranet *client = [[[RESTClientKIntranet alloc]init]autorelease];
        
        client.delegate = self;
        
        [client refreshStaffList];
    }
}

- (void)viewDidUnload
{
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setUserid:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.employees count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StaffCell"];
    Staff *staff = [self.employees objectAtIndex:indexPath.row];
    cell.textLabel.text = staff.name;
    cell.detailTextLabel.text = staff.location;
    
    if (staff.checkin != nil && staff.checkout != nil)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm dd/MM/yyyy"];
        
        //Optionally for time zone converstions
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSString *stringFromDate = [formatter stringFromDate:staff.checkin];
        
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:@ " - "];

        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:stringFromDate];
        
        cell.textLabel.textColor = [UIColor redColor];
        
        [formatter release];
    }
    else
    {
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    if (staff.selected == FALSE)
    {
        cell.imageView.hidden = TRUE;
    }
    
    return cell;
}

- (IBAction)checkInStaff:(id)sender {
    selectedCells = [self.tableView indexPathsForSelectedRows];
    
    for (int i = 0; i < selectedCells.count; i++)
    {
        NSIndexPath *path = [selectedCells objectAtIndex:i];
               
        Staff *staff = [self.employees objectAtIndex:[path row]];
        staff.selected = FALSE;
        staff.location = @"Melbourne Office";
        staff.checkin = nil;
        staff.checkout = nil;
        staff.modified = YES;
    }
    
    RESTClientKIntranet *client = [[[RESTClientKIntranet alloc]init]autorelease];
    
    client.delegate = self;
    
    [client updateStaffLocation:employees];
    
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    self.navigationItem.leftBarButtonItem.enabled = FALSE;
    
    [self.tableView reloadData];
}

#pragma mark - Table view delegate


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].imageView.hidden = TRUE;
    
    selectedCells = [self.tableView indexPathsForSelectedRows];
    
    if (selectedCells.count == 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
        self.navigationItem.leftBarButtonItem.enabled = FALSE;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].imageView.hidden = FALSE;

    Staff *staff = [self.employees objectAtIndex:indexPath.row];
    staff.selected = TRUE;
    
    selectedCells = [self.tableView indexPathsForSelectedRows];
    
    if (selectedCells.count > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
        self.navigationItem.leftBarButtonItem.enabled = TRUE;
    }
}


-(BOOL)loginToKIntranet:(LoginViewController *)controller currentUserid:(NSString *)authenticatedUserId currentFirstName:(NSString *)authenticatedFirstName currentLastName:(NSString *)authenticatedLastName
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    appDelegate.isAuthenticated = true;
    
    return YES;
}

-(void)logoutUser:(MyViewController *)controller
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    appDelegate.isAuthenticated = FALSE;
    
    [self handleLogin];
}

#pragma mark - PlayerDetailsViewControllerDelegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Checkout"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        CheckoutViewController *checkoutViewController = [[navigationController viewControllers] objectAtIndex:0];
        checkoutViewController.delegate = self;
    }
}

-(NSArray*)selectedStaff:(CheckoutViewController *)controller
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected = TRUE"];

    NSArray *selected = [[self employees] filteredArrayUsingPredicate:predicate];
    
    return selected;
}

-(void)checkoutViewControllerDidCancel:(CheckoutViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)checkoutViewControllerDidSave:(CheckoutViewController *)controller
{
    RESTClientKIntranet *client = [[[RESTClientKIntranet alloc]init]autorelease];
    
    client.delegate = self;
    
    [client updateStaffLocation:employees];
    
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    self.navigationItem.leftBarButtonItem.enabled = FALSE;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString {
    
    // Setup Date & Formatter
    NSDate *date = nil;
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:en_US_POSIX];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [en_US_POSIX release];
    }
    
    /*
     *  RFC3339
     */
    
    NSString *RFC3339String = [[NSString stringWithString:dateString] uppercaseString];
    RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
    
    // Remove colon in timezone as iOS 4+ NSDateFormatter breaks
    // See https://devforums.apple.com/thread/45837
    if (RFC3339String.length > 20) {
        RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":"
                                                                 withString:@""
                                                                    options:0
                                                                      range:NSMakeRange(20, RFC3339String.length-20)];
    }
    
    if (!date) { // 1996-12-19T16:39:57-0800
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
        date = [formatter dateFromString:RFC3339String];
    }
    if (!date) { // 1937-01-01T12:00:27.87+0020
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
        date = [formatter dateFromString:RFC3339String];
    }
    if (!date) { // 1937-01-01T12:00:27
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
        date = [formatter dateFromString:RFC3339String];
    }
    if (date) return date;
    
    /*
     *  RFC822
     */
    
    NSString *RFC822String = [[NSString stringWithString:dateString] uppercaseString];
    if (!date) { // Sun, 19 May 02 15:21:36 GMT
        [formatter setDateFormat:@"EEE, d MMM yy HH:mm:ss zzz"];
        date = [formatter dateFromString:RFC822String];
    }
    if (!date) { // Sun, 19 May 2002 15:21:36 GMT
        [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
        date = [formatter dateFromString:RFC822String];
    }
    if (!date) {  // Sun, 19 May 2002 15:21 GMT
        [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm zzz"];
        date = [formatter dateFromString:RFC822String];
    }
    if (!date) {  // 19 May 2002 15:21:36 GMT
        [formatter setDateFormat:@"d MMM yyyy HH:mm:ss zzz"];
        date = [formatter dateFromString:RFC822String];
    }
    if (!date) {  // 19 May 2002 15:21 GMT
        [formatter setDateFormat:@"d MMM yyyy HH:mm zzz"];
        date = [formatter dateFromString:RFC822String];
    }
    if (!date) {  // 19 May 2002 15:21:36
        [formatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
        date = [formatter dateFromString:RFC822String];
    }
    if (!date) {  // 19 May 2002 15:21
        [formatter setDateFormat:@"d MMM yyyy HH:mm"];
        date = [formatter dateFromString:RFC822String];
    }
    if (date) return date;
    
    // Failed
    return nil;
    
}

- (void)dealloc {
    [super dealloc];
}


@end
