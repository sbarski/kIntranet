//
//  CheckoutViewController.m
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "CheckoutViewController.h"

@interface CheckoutViewController ()

@end



@implementation CheckoutViewController

@synthesize location;
@synthesize checkin;
@synthesize checkout;

@synthesize delegate;
@synthesize locationTextField;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setDateTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"HH:mm dd/MM/yyyy"];
    
    if (checkin != nil)
    {
        NSIndexPath *checkInIndexPath = [[[NSIndexPath alloc] initWithIndex:1]autorelease];
        
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:checkInIndexPath];
        cell.textLabel.text = [formatter stringFromDate:checkin];
    }
    
    if (checkout != nil)
    {
        NSIndexPath *checkOutIndexPath = [[[NSIndexPath alloc] initWithIndex:2]autorelease];
        
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:checkOutIndexPath];
        cell.textLabel.text = [formatter stringFromDate:checkout];
    }
    
    [formatter release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDateTime];

    checkout = [NSDate date];
    checkin = [[NSDate date] dateByAddingTimeInterval:3600];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setLocationTextField:nil];
    [self setCheckin:nil];
    [self setCheckout:nil];
    [self setLocation:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}
 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = FALSE;
    
    //wrong delegate?
    //checkout = [NSDate date];
    //checkin = [[NSDate date] dateByAddingTimeInterval:3600];
    
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        [self.locationTextField becomeFirstResponder];
    }
    else if (indexPath.section > 0)
    {
        [self showDatePicker:indexPath.section];
    }

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void)showDatePicker:(NSInteger)section
{
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Select date and time" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
    UIDatePicker *pickerView = [[UIDatePicker alloc]init];
    
    if (section == 1 && checkout != nil)
    {
        [pickerView setDate:[self checkout]];
    }
    
    if (section == 2 && checkin != nil)
    {
        [pickerView setDate:[self checkin] animated:YES];
    }
    
    menu.tag = section;

    pickerView.datePickerMode = UIDatePickerModeDateAndTime;
    [menu addSubview:pickerView];
    [menu showInView:self.view];
    
    CGRect menuRect = menu.frame;
    CGFloat orgHeight = menuRect.size.height;
    menuRect.origin.y -= 214;
    menuRect.size.height = orgHeight + 300;
    menu.frame = menuRect;
    
    CGRect pickerRect = pickerView.frame;
    pickerRect.origin.y = 174;
    pickerView.frame = pickerRect;

    [pickerView release];
    [menu release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIDatePicker *datePicker = [[actionSheet subviews] objectAtIndex:3];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:actionSheet.tag];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
        [formatter setDateFormat:@"HH:mm dd/MM/yyyy"];
        
        //Update the labels and save dates
        switch (actionSheet.tag) {
            case 1:
                checkout = datePicker.date.copy;

                cell.textLabel.text = [formatter stringFromDate:checkout];
                [cell.textLabel sizeToFit];
                break;
                
            case 2:
                checkin = datePicker.date.copy;

                cell.textLabel.text = [formatter stringFromDate:checkin];
                [cell.textLabel sizeToFit];
                break;
                
            default:
                break;
        }
    }
}

-(IBAction)cancel:(id)sender
{
    [self.delegate checkoutViewControllerDidCancel:self];
}

-(IBAction)done:(id)sender
{
    //NSMutableArray *arr = [self.delegate staffViewController:self].employees;
    
    //[self.delegate staffViewController:self employees]
    //StaffViewController *appDelegate = (StaffViewController *)[[UIApplication sharedApplication] delegate];
    
    for (Staff *staff in [self.delegate selectedStaff:self])
    {
        staff.checkin = checkin;
        staff.checkout = checkout;
        staff.selected = FALSE;
    }
    
    [self.delegate checkoutViewControllerDidSave:self];
}

- (void)dealloc {
    [locationTextField release];
    [checkin release];
    [checkout release];
    [location release];
    [super dealloc];
}
@end
